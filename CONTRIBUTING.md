# Contributing Guide

Welcome! We are glad that you want to contribute to our project! 💖

If you'd like to report a bug or suggest a feature or get in touch with the repository owners for any other reason, the best way to do this is by opening an issue on the repository.

In case of a bug report, please be as precise in your description, include all the relevant information, such as the version of the Lambda function you used (Git commit SHA, branch name etc.), your OS, environment, Lambda configuration etc. 

If you'd like to contribute to our code or documentation, the best way to go about this is to first open an issue (if you have e.g. a new feature you'd like to contribute) and discuss with the repository owners, before submitting the change itself.

## Pull Request Process

We require all of our commits to be signed, please make sure they are signed by following [this guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

1. Before opening a PR, ensure all checks (formatting, lint, tests) are passing locally by running the `make package` target.
2. Optionally, if you'd like to check the functionality of your changes, you can run a manual test on your own AWS account - the resulting `bootstrap.zip` afer running `make package` can be used for upload and testing.
3. If you're PR is not ready for a review yet, please mark it as a draft.
4. Reviewers will get to your PR as soon as possible. In order for your PR to be merged, all substantial comments must be addressed and at least **1** approval from a repository owner is required.

## Release Process

For each new version a GitHub release is created. To prepare a new release, follow these steps:

1. Make sure all the changes you want to release are merged into the `main` branch and you have latest `main` branch checked out locally.
2. Create a tag for the new version on your local machine by running the following. Replace `<semantic_version>` with the new version number:
```
   tag=<semantic_version>
   git tag -s "v${tag}" -m "v${tag}"
```
3. Push the tag to GitHub:
```
   git push origin "v${tag}"
```
4. GitHub action will automatically create a new _draft_ release after running all the required CI jobs.
5. Once the draft release is created, go to [Releases](https://github.com/coralogix/cloudwatch-metric-streams-lambda-transformation/releases) page and open the new draft release. Edit the release notes as needed and double check that the `bootstrap.zip` file is attached to the release.
6. Once everything is ready, publish the release.

## Requried cahnge
When you submite a change to module you will need to make sure that you made all of the necessary change:
- Update the CHANGELOG.md file of the module
- In case that you add a variable make sure that you also add him to the example/<module name>/variable.tf and README files

## Pull Request Checklist

When you submit your pull request, or you push new commits to it, our automated
systems will run some checks on your new code. We require that your pull request
passes these checks, but we also have more criteria than just that before we can
accept and merge it. We recommend that you check the following things locally
before you submit your code:

- CLA,
- passing CI
- resolved discussions