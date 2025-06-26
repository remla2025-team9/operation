## Context and problem statement

Our project has a thorough and powerful operational setup, allowing deployment on both Docker Compose for quick local tasks and a multi-node Kubernetes cluster for mimicking production. While this flexibility is a strength, the onboarding and setup process for the Kubernetes environment has become a significant, release-engineering-related shortcoming.

Currently, a developer wanting to set up a local Kubernetes environment using Minikube must follow a long and fragile sequence of manual commands outlined in the `operation` repository's `README.md`. This process involves orchestrating multiple complex tools (`minikube`, `istioctl`, `kubectl`, `helm`) and performing privileged system modifications.

In practice, this manual setup process introduces several critical issues:

*  **Too many of commands:** A developer must precisely execute a dozen or more commands in a specific order. This includes starting Minikube with exact resource flags (`--cpus 6 --memory 6144`), enabling addons, installing Istio, applying addon YAMLs (`jaeger.yaml`, `kiali.yaml`), and labeling the `default` namespace for sidecar injection.

*  **Error-prone manual system modification:** The most fragile step requires the developer to manually find the Minikube Ingress IP and then edit their local `/etc/hosts` file using `sudo`. A typo, an incorrect IP, or a forgotten hostname leads to a completely non-functional setup with complex errors that are difficult for new members to debug.

*  **Environment inconsistency:** The manual process makes it easy to introduce subtle differences between developer environments. One developer might use a slightly different version of Istio, forget to label the namespace, or allocate insufficient memory to Minikube. This leads to the classic "it works on my machine" problem, where bugs become impossible to reproduce and CI/CD behavior differs from the local setup.

*  **Security and permission obstacles:** The process requires `sudo` privileges to modify a critical system file (`/etc/hosts`). This is not only a potential security risk but can also be a blocker in restricted corporate environments. Furthermore, the command provided (`sudo sh -c "echo '...' >> /etc/hosts"`) can create duplicate entries if run more than once, cluttering the file and causing potential resolution issues.

The core problem is that our developer onboarding relies on **manual instructions** rather than an **automated, declarative definition** of the required environment. This fragility weakes our ability to quickly and reliably spin up consistent development environments.


## Why it matters

The current setup procedure creates risks and inefficiencies that affect the entire project. The consequences of relying on this manual process are felt in four key areas: developer productivity, project stability, team onboarding, and engineering consistency.

*   **Significant loss of developer productivity**  
    The manual process directly impacts the team's efficiency. A single mistake during the multi-step setup, such as a typo in a command or an incorrect IP address, can lead to a broken environment that could take **30 to 60 minutes** to diagnose and fix. This is not a one-time cost but a recurring one, affecting developers whenever they need to create or reset their environment. This time is diverted from core project work—like developing new features or improving our models—and spent on repetitive, low-value troubleshooting.

*   **Increased risk of integration errors**  
    When each developer's environment is configured by hand, small but meaningful differences between them are inevitable. These inconsistencies create a classic "it works on my machine" scenario, where code that passes locally fails in the shared Continuous Integration (CI) pipeline. These failures disrupt the workflow for the entire team, requiring valuable time to investigate and fix broken builds. This undermines the reliability of our automated quality checks and slows the overall pace of delivering new functionality.

*   **Slower onboarding for new team members**  
    A project's complexity should be in its technical challenges, not its setup instructions. The current lengthy and error-prone process presents a significant hurdle for new contributors. Instead of becoming productive quickly, their initial experience is often focused on navigating complex steps and debugging their environment. This not only slows down their ability to contribute meaningfully but can also be discouraging for someone new to the project.

*   **Lack of environment reproducibility**  
    Our project is committed to the principle of reproducibility, especially regarding our data and models. This same standard should apply to our development environments. An environment that cannot be created automatically and reliably is, by definition, not reproducible. This inconsistency at the foundational level weakens our ability to guarantee that local tests and experiments will behave the same way in our production environment, creating a gap between development and deployment.



## Extension proposal

To fix the problems caused by our manual setup, we will introduce an automated system that handles the entire Kubernetes environment creation. For this, we will use a **`Makefile`**. A `Makefile` is a standard file used in software projects to define simple shortcuts for complex command-line tasks. It allows us to bundle a long sequence of commands into a single, easy-to-remember command, like `make setup`.

Our proposed solution is built on three key components, which work together to create a smooth and reliable experience for every developer:

---

#### **Component 1: A single command center (the `Makefile`)**

This part is about creating one central place for all setup commands.

The `Makefile` will act as our project's main control panel. Instead of requiring developers to read a long document and copy-paste over a dozen commands, they will only need to use a few simple, intuitive actions:

*   **`make setup`:** This single command will prepare the entire local Kubernetes cluster, including starting the necessary services and applying all configurations automatically.
*   **`make deploy`:** This command will install our complete application onto the prepared cluster.
*   **`make clean`:** This command will completely remove the environment, stopping all services and cleaning up any system changes made during setup.

This turns our setup instructions into an executable tool, allowing developers to focus on their work instead of getting bogged down in procedural details.

---

#### **Component 2:  Smart, error-proof automation**

This part is about making the automation intelligent so it doesn't break things or repeat work unnecessarily.

A key feature of this new system is that it will be smart enough to check the status of the environment before acting. This makes the setup process reliable and efficient, because it's safe to run at any time. For example:

*   **It Checks if the Cluster is Already Running:** Before trying to start the local Kubernetes cluster, the script will first check if it’s already active. If it is, the script will simply report that and move on, saving time and preventing errors.
*   **It Verifies Configurations First:** The script will check if configurations are already in place before trying to apply them. If a setting is already correct, the script won't waste time applying it again.

This design ensures the setup process is robust. A developer can run `make setup` on a brand new computer or on one where the setup was only halfway done. In both cases, the final result will be a fully working environment, with no manual steps needed.

---

#### **Component 3: Safe and automatic system file updates**

This part addresses the most fragile step of the current process: editing a critical system file.

The script will fully and safely automate all changes to the system's `hosts` file.

1.  **It Finds the Right IP Address Automatically:** The script will automatically detect the correct IP address for the local cluster. This removes the need for developers to manually copy and paste it, a common source of mistakes.
2.  **It Makes Clean and Reversible Updates:** Instead of just adding new lines to the `hosts` file—which can lead to clutter and future conflicts—the script will work more cleanly. It will first remove any old entries related to our project before adding the correct new ones. When the environment is removed with `make clean`, these entries will be deleted automatically, leaving the system as it was before.

While this step will still require administrative permission, all the complex and risky logic is now handled by a tested, reliable script. This eliminates the risk of human error and frees the developer from worrying about the details.



## The new developer workflow

The most effective way to understand the impact of this change is to compare the developer's journey before and after its implementation. The difference is a move from a long, fragile procedure to a simple, reliable one.

### **Before: The Old, Manual Process**

A developer setting up the project for the first time had to follow a precise and unforgiving sequence of steps. This journey was filled with opportunities for error:

1.  Start the local cluster with very specific memory and CPU settings.
2.  Enable a required feature on the cluster.
3.  Install a separate, complex tool called Istio.
4.  Apply several configuration files for Istio's addons.
5.  Run a specific command to label a part of the cluster.
6.  Navigate into the `app-helm-chart` directory.
7.  Download chart dependencies.
8.  Install the application using Helm.
9.  **Open a new, separate terminal** and run a command (`minikube tunnel`) that must be left running in the background. Forgetting this step breaks the entire setup.
10. Find and copy the correct IP address from the terminal output.
11. Use administrator privileges (`sudo`) to manually edit the system's `hosts` file, pasting the IP address and hostnames.
12. Finally, cross their fingers and open the browser, hoping everything was done correctly.

If any of these 12 steps were performed incorrectly, the developer would face confusing errors and a lengthy debugging session.

### **After: The New, Automated Process**

With the `Makefile` in place, the developer's journey is dramatically simplified. All the complexity of the old process is now handled behind the scenes.

1.  Open a terminal and run `make setup`.
    *   This single command automatically handles all the preparation steps: starting the cluster, installing tools, and configuring the system correctly.
2.  Run `make deploy`.
    *   This command deploys our application to the fully prepared environment.

That's it. The developer is ready to start working. To shut everything down, they just run `make clean`.

### **Visualizing the Difference**

The diagrams below show how the developer's interaction with the system changes. We move from a long chain of manual tasks to a simple, automated workflow.

**Before: A long and fragile path**
```mermaid
graph TD
    Dev[Developer] --> A[Start Minikube];
    A --> B[Enable Addons];
    B --> C[Install Istio];
    C --> D[Apply Configs];
    D --> E[Label Namespace];
    E --> F[Run Helm];
    F --> G[Run Tunnel];
    G --> H[Edit hosts File];
    H --> Result{Working?<br/>(Maybe)};
```

**After: A simple, reliable path**
```mermaid
graph TD
    Dev[Developer] --> MakeSetup{Run `make setup`};
    subgraph "Automation Hides Complexity"
        MakeSetup --> A[Starts Minikube];
        A --> B[Installs Istio];
        B --> C[Configures System];
        C --> D[Ready for Deployment!];
    end
    D --> Deploy{Run `make deploy`};
    Deploy --> Result[Working!<br/>(Guaranteed)];
```


## How to test the improvement

To prove that our new automated setup is better, we need to do more than just say it's easier; we need to measure it. The goal of this change is to improve the experience for developers, so our test should focus on human factors like time, errors, and satisfaction.

We will design a simple experiment to compare the old manual process against the new automated one.

### **Our Hypothesis**

We believe that **developers using the new `Makefile` will be able to set up a working environment significantly faster, with fewer errors, and with less frustration than developers using the old manual instructions.**

### **The Experiment Design**

We will run a user test with two groups of participants. The ideal participants would be developers from our team who have *not* yet set up the project on their current machine, or even volunteers from outside the team who are unfamiliar with the project.

1.  **Form Two Groups:**
    *   **Group A (The Control Group):** This group will be given the current `README.md` with the long, manual list of instructions.
    *   **Group B (The Test Group):** This group will be given a revised `README.md` that instructs them to use the new `make` commands.

2.  **Give Them a Clear Task:**
    The task for both groups will be the same: "Follow the instructions to set up the complete application stack on your machine and access the application's front-end in your browser."

3.  **Measure the Results:**
    To get a complete picture, we will measure three things:
    *   **Time to Success (Quantitative):** We will time how long it takes each participant, from starting the instructions to successfully loading the application in their browser. A shorter time is better.
    *   **Number of Errors or "Help" Requests (Quantitative):** We will count how many times a participant runs into an error they cannot solve on their own or has to ask for help. Fewer errors indicate a clearer, more robust process.
    *   **User Satisfaction (Qualitative):** After the task is complete, we will ask each participant to rate the setup process on a scale of 1 to 5 for clarity, ease of use, and overall frustration. Higher scores are better.

### **Defining Success**

We will consider this extension a success if the results show a clear improvement for Group B (the `Makefile` users). Specifically, we will be looking for:

*   A **statistically significant reduction** in the average time it takes to complete the setup.
*   A **noticeably lower number** of errors and requests for help.
*   **Consistently higher satisfaction scores** reported by the participants.

By running this experiment, we can gather real evidence that our automated solution not only works but also delivers a measurably better and more efficient experience for our entire team.


## Supporting references