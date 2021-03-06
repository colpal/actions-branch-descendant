# Branch Descendant

This action checks that a branch's nearest MST ancestor is the Master branch. If the nearest MST ancestor is master, then the action will succeed, otherwise it will fail. In either case the action returns the outputs listed below. The commit hashes followed to reach the closest MST parent branch are available in the action's logs, but are not returned as a variable for other actions to use. To see sample output from this action, check the pull requests and actions tabs of this repo. Read more about MST here: https://github.com/colpal/MST-branching.

## Inputs

### None

## Outputs

### `valid`

#### Valid MST
A boolean indicating whether or not the closest MST ancestor branch is the Master branch. Either `true` or `false`.

### `PR-string`

#### Pretty String for PRs

A pretty string indicating whether or not the closest MST ancestor branch is the Master branch. Either `"Master branch is closest MST parent. PR good to go 👍"` or `"Master branch should be the closest MST parent. PR not good to go 👎"`.

### `closest-MST-parent`

#### Closest MST Ancestor

A string indicating which MST branch is the closest ancestor to the branch being considered. Either `"Master"`, `"Develop"`, or `"Test"`.

## Example usage

The following example runs the action on every pull request to the develop, test, or master branches. It then prints out the three outputs in the workflow logs, and leaves a comment containing the three outputs on the PR.  
* Note that `continue-on-error` is set to `true` for this action. If this is not set, the action will fail when the nearest MST ancestor branch is not master, which will cause the action to fail. This may or may not be desirable depending on your use case.  
* Also note that `ref` is set to `${{ github.head_ref }}` in `actions/checkout@v2`. This is so that the action is checking the 'compare' branch and not the 'base' branch of the PR. Without this the action is unlikely to perform as expected.

```
name: Branch Descendant Validation
on:
  pull_request:
    branches:
      - develop
      - test
      - master
jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
          ref: ${{ github.head_ref }}

      - name: Run colpal/actions-branch-descendant
        id: actions-branch-descendant
        continue-on-error: true
        uses: colpal/actions-branch-descendant@master
          
      - name: Update Pull Request
        uses: actions/github-script@0.9.0
        env:
          VALID: "${{ steps.actions-branch-descendant.outputs.valid }}"
          PR_STRING: "${{ steps.actions-branch-descendant.outputs.PR-string }}"
          PARENT: "${{ steps.actions-branch-descendant.outputs.closest-MST-parent }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `### ${ process.env.PR_STRING }
            #### Closest MST parent branch needs to be: \`Master\`.
            #### Closest MST parent branch is: \`${ process.env.PARENT }\`.
            #### Closest MST parent is Master? \`${ process.env.VALID }\`.
            #### Read more about MST here: https://github.com/colpal/MST-branching.
            ### ${ process.env.PR_STRING }`;
              
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
```
