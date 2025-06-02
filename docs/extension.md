# Streamlining Release Automation for Istio-Enabled Workload

## 1. Context and Problem Statement

Over the last few sprints, our DVC pipeline sometimes fails at the preprocessing stage because `preprocessor.joblib` is tracked as an output. Even when neither the raw data nor the preprocessing script changes, the serialized transformer’s checksum varies on each run. That leads to messages like:

```
WARNING: Some cache files do not exist… Missing cache files: edcffd9f…
ERROR: failed to pull data from the cloud – Checkout failed for preprocessor.joblib
```

In practice, this causes three main issues:

1. **Cloning and pulling from DVC**  
   When team members clone the repository and run `dvc pull` without making any changes, they see a “missing cache” error for `preprocessor.joblib`.

2. **Manual fixes break the pipeline**  
   If someone deletes or replaces `preprocessor.joblib` by hand, downstream stages—feature generation, model training, and evaluation—fail because they expect a stable preprocessor object.

3. **Unreliable CI tests**  
   Automated tests that load `preprocessor.joblib` fail at random. That leaves our CI builds red and blocks merges.

Our goal is to make the pipeline reproducible: after cloning and running `dvc pull`, a simple `dvc repro` should generate the same `preprocessor.joblib` and let all later stages run without manual intervention.

## 2. Why It Matters

- **Wasted developer time**  
  Every “missing cache” incident costs at least 30 minutes of debugging (digging through logs, clearing caches, re-running `dvc add`, etc.). Over weeks, that adds up to several hours.

- **Reproducibility requirements**  
  In research-oriented projects, reproducibility is mandatory. When preprocessor artifacts change unpredictably, we cannot be sure experiments on one machine match those on another.

- **Fragile CI**  
  Our GitHub Actions CI assumes `dvc pull && dvc repro` will succeed. With the current setup, PRs often fail CI tests and require manual fixes or skipped tests. That undermines validation.

- **Onboarding difficulty**  
  New team members or interns spend more time fixing DVC problems than understanding our pipeline’s logic. That creates a bad first impression.

## 3. Proposed Fix: Deterministic Preprocessing and DVC Cleanup

I suggest a two-part approach:

### A. Stop Tracking `preprocessor.joblib` Directly in DVC

1. **Reason**  
   DVC is ideal for tracking large files whose contents stay the same when inputs do not change. Our `preprocessor.joblib` includes metadata—timestamps or memory addresses—that change on every run. As a result, its checksum fluctuates even if code and data are unchanged.

2. **Implementation steps**  
   - Run:
     ```bash
     dvc remove preprocessor.joblib.dvc
     git rm preprocessor.joblib.dvc
     git commit -m "Stop tracking preprocessor.joblib in DVC"
     ```
   - Add `preprocessor.joblib` to both `.gitignore` and `.dvcignore`:
     ```
     # .gitignore and .dvcignore
     preprocessor.joblib
     ```

3. **Effect**  
   From now on, `preprocessor.joblib` will be generated when needed by a DVC stage instead of being fetched from cache. That way, DVC will not try to pull or push an outdated version with the wrong checksum.

### B. Add a Deterministic “Preprocess” Stage with a Fixed Seed

1. **Reason**  
   If our preprocessing script uses a fixed random seed (for example, 42), then running
   ```
   python scripts/preprocess.py --seed 42 --output data/preprocessor.joblib
   ```
   on the same code and raw data will always produce a byte-for-byte identical file. Any random imputations or shuffle orders will follow the same pattern each time.

2. **Concrete changes**  
   - Modify `scripts/preprocess.py` to accept a `--seed` argument (use `argparse`) and call `np.random.seed(seed)` (or the equivalent) before any operations that involve randomness.  
   - Update `dvc.yaml` to include a `preprocess` stage:
     ```yaml
     stages:
       preprocess:
         cmd: python scripts/preprocess.py --seed 42 --output data/preprocessor.joblib
         deps:
           - scripts/preprocess.py
           - data/raw/training_data.tsv
         outs:
           - data/preprocessor.joblib
     ```
   - Adjust tests and downstream scripts (feature engineering, model fitting, evaluation) to load `data/preprocessor.joblib` from that path. In `tests/test_preprocessor.py`:
     ```python
     import joblib
     from pathlib import Path

     PREPROCESSOR_PATH = Path("data/preprocessor.joblib")

     def test_preprocessor_features():
         assert PREPROCESSOR_PATH.exists(), "Run `dvc repro` to generate preprocessor.joblib"
         pre = joblib.load(PREPROCESSOR_PATH)
         # ... existing feature validation logic ...
     ```

3. **Outcome**  
   With a fixed seed, data, and code, DVC will cache exactly one version of `data/preprocessor.joblib`. Future `dvc repro` and `dvc pull` will find the correct hash in the remote cache, and the pipeline will run without failures.

## 4. CI Hash Verification

Even with a deterministic artifact, we need to make sure CI detects unintended changes. To do that:

1. **Create** `expected_hashes.txt` at the repository root (alongside `dvc.yaml`). Add a line like:
   ```
   data/preprocessor.joblib 3a7d4f8c9eb2f1a6f68fa2d45e7b9c3a2cdefab1234567890abcdef1234567890
   ```
   (Replace the hex string with the actual SHA-256 hash of the artifact generated by running `dvc repro` on the current raw data.)

2. **Modify** `.github/workflows/ci.yml` to include these steps after `dvc pull && dvc repro --no-run-cache`:
   ```yaml
   - name: Verify preprocessor.joblib hash
     run: |
       echo "Checking preprocessor.joblib consistency"
       ACTUAL=$(sha256sum data/preprocessor.joblib | cut -d' ' -f1)
       EXPECTED=$(grep data/preprocessor.joblib expected_hashes.txt | awk '{print $2}')
       if [ "$ACTUAL" != "$EXPECTED" ]; then
         echo "✖ Hash mismatch! Actual: $ACTUAL"
         echo "  Expected: $EXPECTED"
         exit 1
       fi
       echo "✔ preprocessor.joblib is up-to-date"
   ```

3. **Document** the procedure for updating the hash when data or code changes:
   ```bash
   # After changing data or code:
   dvc repro --no-run-cache
   sha256sum data/preprocessor.joblib | awk '{print $1}' > expected_hashes.txt
   git add data/preprocessor.joblib expected_hashes.txt
   git commit -m "Update preprocessor hash after data change"
   ```
   This makes sure CI remains green and that any change to the preprocessor is intentional and recorded.

## 5. Developer Convenience

To help developers regenerate `preprocessor.joblib` without running the full DVC pipeline:

- **Add** a `Makefile` or shell script. For instance, in `Makefile`:
  ```makefile
  .PHONY: preproc
  preproc:
      python scripts/preprocess.py --seed 42 --output data/preprocessor.joblib
  ```
- **Update** `README.md` under “Local setup”:
  > **Rebuild the Preprocessor**  
  > If you change raw data or preprocessing code, run:
  > ```bash
  > make preproc
  > ```
  > to recreate `data/preprocessor.joblib`. Then update `expected_hashes.txt` as shown above before committing.

This gives developers a quick way to regenerate the preprocessor without needing to understand DVC internals.

## 6. Revised Pipeline Flow

![Pipeline Flow](https://github.com/user-attachments/assets/bbd649bf-654e-404b-adb9-2f3900c17059)

- **Before:** `preprocessor.joblib` was a DVC-tracked file that changed checksums unpredictably, causing intermittent failures.
- **After:** The “Preprocess” stage in `dvc.yaml` deterministically regenerates the same `preprocessor.joblib`. DVC only needs to manage the code and raw data inputs, not a checksum-volatile artifact.

## 7. Evaluation Plan and Next Steps

1. **Fresh Clone + `dvc pull`**  
   - Clone the repository into a new folder.  
   - Run `dvc pull`. It should download everything except `preprocessor.joblib`, which will be created by the next step.

2. **`dvc repro` Consistency**  
   - Run `dvc repro --no-run-cache`.  
   - Check that `data/preprocessor.joblib` is generated and matches the hash in `expected_hashes.txt`.  
   - Confirm there are no “missing cache” warnings.

3. **Full Pipeline Run**  
   - After repro, run the training and evaluation stages:
     ```bash
     dvc repro train evaluate
     ```
   - Make sure downstream steps finish successfully, producing model artifacts and evaluation reports.

4. **Hash Change on Data Update**  
   - Edit one line in `data/raw/training_data.tsv` (for example, change the case of a category label).  
   - Run `dvc repro --no-run-cache`.  
   - Compute `sha256sum data/preprocessor.joblib`; it should differ from `expected_hashes.txt`.  
   - If the change is intentional, run:
     ```bash
     sha256sum data/preprocessor.joblib | awk '{print $1}' > expected_hashes.txt
     git add expected_hashes.txt data/preprocessor.joblib
     git commit -m "Update preprocessor hash after data change"
     ```
   - Push and observe that CI passes once `expected_hashes.txt` is updated.

5. **CI Validation**  
   - Open a new pull request with a minor change (e.g., a comment edit).  
   - CI should run `dvc pull && dvc repro`, then hash verification.  
   - Confirm there are no “missing cache” errors or hash mismatches.

6. **Team Approval**  
   - Ask a few colleagues to clone, run `dvc pull`, then `dvc repro`, and finally run the tests.  
   - Gather feedback. If anyone still sees a “missing cache” error, revise until it works smoothly.

Once these steps are complete, our pipeline will run reliably across machines, and new contributors can set it up without hassle.

---

### Supporting References

1. **DVC – Versioning Data and Models**  
   https://dvc.org/doc/use-cases/versioning-data-and-models  
2. **DVC – `repro` Command Reference**  
   https://dvc.org/doc/command-reference/repro  
3. **StackOverflow: “DVC Missing Cache Files”**  
   https://stackoverflow.com/questions/79434576/how-to-overcome-missing-cache-files-with-dvc  
4. **scikit-learn Issue: Non-deterministic Pickle Output**  
   https://github.com/scikit-learn/scikit-learn/issues/12345
