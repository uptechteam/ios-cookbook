# git flow

We use [GitHub](https://github.com) and [BitBucket](https://bitbucket.org/product) for our projects.

## Commits

- Write grammatically correct (i.e. start with a capital) commit messages in [imperative, present tense](https://stackoverflow.com/questions/3580013/should-i-use-past-or-present-tense-in-git-commit-messages).
- Prefer concise commits over gigantic ones. When writing a concise commit message is difficult, it may indicate too many unrelated changes.

## Branches

### Types

In our workflow we have several branches:

- `master` that always contains latest production code from AppStore;
- `develop` that is used for staging purposes and should be always buildable;
- `feature/*` branches. For every fix or feature you should create a separate branch. When you are done, create a Pull Request to the `develop`. There are some naming variations that you are free to use, like `fix/*`, `refactor/*`.

### Merging

We use Pull Requests to merge any change to the `develop` or `master` branch. Sometimes it's ok to push a hotfix directly into the `develop` when the sky is falling, otherwise, please, use Pull Requests. This rule enforces [collective code ownership](https://martinfowler.com/bliki/CodeOwnership.html).

## Code Review

### As a submitter:

#### 1. Keep it short
![](https://nyu-cds.github.io/effective-code-reviews/fig/code-review-best-practices-figure-01.gif)  
Ideally, your Pull Request shouldn't exceed 400 lines of code. Beyond 200 lines and the effectiveness of a review drops significantly. By the time you’re at more than 400 they become almost pointless.

#### 2. Provide context
Ensure that your commit messages explain what you are trying to achieve and why. Link to any related tickets, or the specification. It’ll help the reviewer and you’ll get fewer issues coming back.

#### 3. Review yourself
Take a short break and review your Pull Request. Your changes look suprizingly different when presented as a git diff.

### As a reviewer:

#### 1. Adopt a positive attitude
Assume best intentions, and address the code rather than the person writing the code. **Criticism should never be personal.**

#### 2. Take your time
Do code reviews often and for short sessions. The effectiveness of your reviews decreases after around an hour. So putting off reviews and doing them in one almighty session doesn’t help anybody.

#### 3. Give compliments
During your code review you have noticed interesting approach or brilliant solution? Say it! Getting props from your colleagues is one of the best feelings ever.

### As a reviewer:

If your next pull request is really that intimately related to your last, consider to continue working on it instead of opening another.

If it really makes sense to open another, it's okay to base your next pull request on your unmerged branch. Request that it be merged to the main branch, though, and be sure to merge any changes you've made to its parent during its review.

-

P.S. There are times when pull requests are quite large, or it is referencing existing code not found in the PR, or you for some other reason do not have a good enough context to review anything else than code style and typos. In these cases, we encourage you to go through the pull request together with the submitter, either physically or virtually.

Be warned, though: By doing this, you will both need to explain your thoughts and discuss other alternatives. Of course, this means you are putting yourself at risk of sharing your knowledge and/or learning some new stuff, so please be careful not to end up being even more awesome than you are.


