# Assignment 1

### Basic requirements

| Requirement | Status | Explanation |
|------------|--------|-------------|
| Data Availability | **Pass** | The GitHub organization follows the requested template and all the relevant information is accessible. The `operation` folder contains the `grading.md` file. |
| Sensible Use Case | **Pass** | The frontend allows querying the model and additional interactions that allow the user to change incorrect predictions exist. |

# Assignment 2

### Setting up (Virtual) Infrastructure
| Task | Status | Explanation |
|------|--------|-------------|
| Sufficient | ✅ | - All the VMs exist, can be booted, and have correct hostnames. <br> - The VMs are attached to a private network and can directly communicate with all other VMs. Vagrant sets the network of each VM to `private_network` and attributes to each node their respective ip. <br> - The VMs are directly reachable from the host through a host-only network. <br> - The VMs are provisioned with Ansible and the provisioning finishes within a maximum of 5 minutes. |
| Good | ✅ | - The Vagrantfile uses a loop and template arithmetic when defining node names or IPs. <br> - The specifications of the provisioned workers are controlled via variables that can be setup before provisioning. |
| Excellent | ✅ | - Extra arguments are passed to Ansible from Vagrant, such as the number of workers <br> - Vagrant generates a valid inventory.cfg for Ansible that contains all (and only) the active nodes. |