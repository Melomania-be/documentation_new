# [TO BE COMPLETED] Working on the app
This project functions with the GitHub Flow method, a simple and widely used workflow to collaborate on code. Its main goal is to keep the project stable, organized, and easy to work on as a team.
## Core idea
The `main` branch must always stay stable and working. All development happens in separate branches, and **never** directly on main. Every time a developer wants to add a feature, fix a bug or do anything to the code, they have to create a new branch (please name them clearly), work on that branch and once it is stable, create a pull request, have it reviewed by another dev, and then only can the new code be integrated to the `main` branch, once all possible conflicts are resolved.
## Step-by-step workflow
### 1. Start from an up-to-date main branch
Before starting any work:
```zsh
git checkout main
git pull
```
This ensures you are working with the latest version of the project.
### 2. Create a new branch
Create a branch for your task:
```zsh
git switch -c branch_name
```
### 3. Work on your feature
Work on your feature:
- Write code
- Test it
- Fix issues

### 4. Commit regularly
```zsh
git add .
git commit -m "example commit message"
```
Best practices: 
- Keep commits small
- **Write clear commit messages**. Keep in mind, you are not writing this for you but for all the next devs that will work on the project.

### 5. Push your branch to GitHub
```zsh
git push origin branch_name
```
Your branch is now available online.

### 6. Open a pull request (PR)
On GitHub:
- click “Compare & pull request”
- add:
    - a clear title
    - a description explaining what you did and why

### 7. Code review
Other developers will:
- review your code
- ask questions
- suggest improvements
You can:
- reply to comments
- make changes
- push updates (the PR updates automatically)

### 8. Merge into main
Once approved, your PR is merged into `main`.

## Important rules
- **Never work directly on `main`:** this causes conflicts, unreviewed code and risks breaking the whole project.
- **One branch = one task:** Avoid mixing multiple features in a single branch.
- **A Pull Request is a discussion:** A PR is not just technical: explain your decisions and make your code understandable to others
- **Only open PR's when your code works:** the code should run without problems, no obvious bugs, and if unit tests are available, it should pass them before opening a PR. 

## [TO BE COMPLETED] Deployment: dev and prod servers