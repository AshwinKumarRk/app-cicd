# APP-CI/CD

## Steps to Run
1. Apply the terraform configurations
   `terraform apply`
2. Make a change in code/README.md
3. Stage and commit the changes
4. Push the commits to the feature branch

## Expected Output
5. In Github, Check should pass on pull request (unit tests)
6. In Github, workflow should run after push which starts CodeDeploy process