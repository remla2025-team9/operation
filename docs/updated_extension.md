# Automating Local Kubernetes Environment Setup using a Makefile

This document proposes an automated solution to the local development environment setup process for our sentiment analysis application, replacing manual command sequences with a simple, reliable automation framework. This proposal is specifically written for the Minikube environment setup.

## Context and Problem Statement

Our project has an advanced setup that lets us run it in two ways: using Docker Compose for simple, local tasks, and using a full Kubernetes setup that acts like our live environment. While this flexibility is a major advantage, the process for setting up the Kubernetes environment has become a significant problem.

Currently, any developer who wants to run the project locally on Kubernetes must follow a long and complicated list of manual steps from the `README` file. This involves juggling multiple different tools and making changes to important system files that require administrator access.

This proposal will focus on fixing the setup process for **Minikube**, which is the most common way our team develops locally. While our other setup option (Vagrant) is more automated, it still has some manual steps that could be improved later using the ideas from this proposal.

In practice, the current manual process for Minikube causes several critical issues:

*   **A long list of commands:** A developer has to run over a dozen commands in a precise order. This includes starting the local cluster with specific memory and CPU settings, installing extra tools, applying special configurations, and setting specific system labels.

*   **Risky manual system changes:** The most fragile step requires a developer to find an IP address and then manually edit a critical system file (`/etc/hosts`). A single typo or mistake here can break the entire setup, leading to confusing errors that are very hard for new team members to fix.

*   **Inconsistent setups for each developer:** When everyone sets up their environment by hand, small differences are bound to happen. This leads to the classic "it works on my machine" problem, where code works for one person but fails for another, or breaks in our automated testing system.

*   **Security risks and permission hurdles:** The process requires administrator access to change a core system file. This can be a security concern and is often blocked in certain work environments. Furthermore, running the provided command more than once can make the file messy and cause future problems.

The core of the problem is simple. Our project onboarding relies on following a long list of steps by hand instead of running a single, automated script. This fragility weakens our team's ability to get up and running quickly and reliably.


## Why It Matters

The current setup procedure causes real problems that slow down the entire project. Relying on these manual steps hurts us in four key ways: it wastes time, creates bugs, makes it hard for new people to start, and goes against our own engineering standards.

*   **Significant loss of developer productivity**  
    The manual process is a drain on the team's time. If a developer makes one small mistake during setup, like a typo in a command, their environment breaks. It can then take them **30 to 60 minutes** to figure out what went wrong and fix it. This isn't just a one-time problem, it can happen every time someone needs to set up or reset their computer. All this time is spent fixing setup problems instead of building new features or making our project better.

*   **Increased risk of integration errors**  
    Because everyone sets up their computer by hand, each person's environment ends up being slightly different. This leads to the classic "it works on my machine" problem, where code that works perfectly for one person fails for everyone else when it's added to the main project. These failures cause delays, as the team has to stop and investigate what went wrong. It makes our automated quality checks less trustworthy and slows down our ability to release new updates.

*   **Slower onboarding for new team members**  
    Getting started on a project should be easy. The hard part should be the project's real challenges, not the setup instructions. Our current lengthy and error-prone process is a major roadblock for new contributors. Instead of being able to start contributing right away, they often spend their first days fighting with complex steps and debugging their environment. This is frustrating and can be very discouraging for someone new to the project.

*   **Lack of environment reproducibility**  
    Our project is built on the idea that our work should be reproducible, meaning our results should be consistent and reliable. This same standard should apply to our development environments. An environment that can't be created automatically and reliably is not truly reproducible. This inconsistency at the very foundation of our work means we can't be confident that code tested locally will work the same way for our users, creating a gap between development and deployment.



## Extension Proposal

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

*   **It checks if the cluster is already running:** Before trying to start the local Kubernetes cluster, the script will first check if it’s already active. If it is, the script will simply report that and move on, saving time and preventing errors.
*   **It verifies configurations first:** The script will check if configurations are already in place before trying to apply them. If a setting is already correct, the script won't waste time applying it again.

This design ensures the setup process is robust. A developer can run `make setup` on a brand new computer or on one where the setup was only halfway done. In both cases, the final result will be a fully working environment, with no manual steps needed.

---

#### **Component 3: Safe and automatic system file updates**

This part addresses the most fragile step of the current process: editing a critical system file.

The script will fully and safely automate all changes to the system's `hosts` file.

1.  **It finds the right IP address automatically:** The script will automatically detect the correct IP address for the local cluster. This removes the need for developers to manually copy and paste it, a common source of mistakes.
2.  **It makes clean and reversible updates:** Instead of just adding new lines to the `hosts` file—which can lead to clutter and future conflicts—the script will work more cleanly. It will first remove any old entries related to our project before adding the correct new ones. When the environment is removed with `make clean`, these entries will be deleted automatically, leaving the system as it was before.

While this step will still require administrative permission, all the complex and risky logic is now handled by a tested, reliable script. This eliminates the risk of human error and frees the developer from worrying about the details.



## The New Developer Workflow

The most effective way to understand the impact of this change is to compare the developer's journey before and after its implementation. The difference is a move from a long, fragile procedure to a simple, reliable one.

### **Before: The old, manual process**

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

### **After: The new, automated process**

With the `Makefile` in place, the developer's journey is dramatically simplified. All the complexity of the old process is now handled behind the scenes.

1.  Open a terminal and run `make setup`.
    *   This single command automatically handles all the preparation steps: starting the cluster, installing tools, and configuring the system correctly.
2.  Run `make deploy`.
    *   This command deploys our application to the fully prepared environment.

That's it. The developer is ready to start working. To shut everything down, they just run `make clean`.

### **Visualizing the difference**

The diagrams below show how the developer's interaction with the system changes. We move from a long chain of manual tasks to a simple, automated workflow.

![image](https://github.com/user-attachments/assets/80367383-3eb7-42a0-9bf0-670cea90e7a9)



## How to Test the Improvement

To prove that our new automated setup is better, we need to do more than just say it's easier; we need to measure it. The goal of this change is to improve the experience for developers, so our test should focus on human factors like time, errors, and satisfaction.

We will design a simple experiment to compare the old manual process against the new automated one.

### **Our hypothesis**

We believe that **developers using the new `Makefile` will be able to set up a working environment significantly faster, with fewer errors, and with less frustration than developers using the old manual instructions.**

### **The experiment design**

We will run a user test with two groups of participants. The ideal participants would be developers from our team who have *not* yet set up the project on their current machine, or even volunteers from outside the team who are unfamiliar with the project.

1.  **Form two groups:**
    *   **Group A (The Control Group):** This group will be given the current `README.md` with the long, manual list of instructions.
    *   **Group B (The Test Group):** This group will be given a revised `README.md` that instructs them to use the new `make` commands.

2.  **Give them a clear task:**
    The task for both groups will be the same: "Follow the instructions to set up the complete application stack on your machine and access the application's front-end in your browser."

3.  **Measure the results:**
    To get a complete picture, we will measure three things:
    *   **Time to Success (Quantitative):** We will time how long it takes each participant, from starting the instructions to successfully loading the application in their browser. A shorter time is better.
    *   **Number of Errors or "Help" Requests (Quantitative):** We will count how many times a participant runs into an error they cannot solve on their own or has to ask for help. Fewer errors indicate a clearer, more robust process.
    *   **User Satisfaction (Qualitative):** After the task is complete, we will ask each participant to rate the setup process on a scale of 1 to 5 for clarity, ease of use, and overall frustration. Higher scores are better.

### **Defining success**

We will consider this extension a success if the results show a clear improvement for Group B (the `Makefile` users). Specifically, we will be looking for:

*   A **statistically significant reduction** in the average time it takes to complete the setup.
*   A **noticeably lower number** of errors and requests for help.
*   **Consistently higher satisfaction scores** reported by the participants.

By running this experiment, we can gather real evidence that our automated solution not only works but also delivers a measurably better and more efficient experience for our entire team.


## Supporting References
