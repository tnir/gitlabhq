<!--
# README first!
This MR should be created on `gitlab.com/gitlab-org/security/gitlab`.

See [the general developer security release guidelines](https://gitlab.com/gitlab-org/release/docs/blob/master/general/security/developer.md).

-->

## Related issues

<!-- Mention the GitLab Security issue this MR is related to -->

## Developer checklist

- [ ] **On "Related issues" section, write down the [GitLab Security] issue it belongs to (i.e. `Related to <issue_id>`).**
- [ ] Merge request targets `master`, or a versioned stable branch (`X-Y-stable-ee`).
- [ ] Milestone is set for the version this merge request applies to. A closed milestone can be assigned via [quick actions].
- [ ] Title of this merge request is the same as for all backports.
- [ ] A [CHANGELOG entry] is added without a `merge_request` value, with `type` set to `security`
- [ ] For the MR targeting `master`:
  - [ ] Assign to a reviewer and maintainer, per our [Code Review process].
  - [ ] Ensure it's approved according to our [Approval Guidelines].
  - [ ] Ensure it's approved by an AppSec engineer.
    - If you're unsure who should approve, find the AppSec engineer associated to the issue in the [Canonical repository], or ask #sec-appsec on Slack.
    - Trigger the [`package-and-qa` build]. The docker image generated will be used by the AppSec engineer to validate the security vulnerability has been remediated.
  - [ ] Merge request _must_ close the corresponding security issue.
- [ ] For a backport MR targeting a versioned stable branch (`X-Y-stable-ee`)
  - [ ] Ensure it's approved by a maintainer.

**Note:** Reviewer/maintainer should not be a Release Manager

## Maintainer checklist

- [ ] Correct milestone is applied and the title is matching across all backports
- [ ] Assigned to `@gitlab-release-tools-bot` with passing CI pipelines and **when all backports including the MR targeting master are ready.**

/label ~security

[GitLab Security]: https://gitlab.com/gitlab-org/security/gitlab
[quick actions]: https://docs.gitlab.com/ee/user/project/quick_actions.html#quick-actions-for-issues-merge-requests-and-epics
[CHANGELOG entry]: https://docs.gitlab.com/ee/development/changelog.html
[Code Review process]: https://docs.gitlab.com/ee/development/code_review.html
[Approval Guidelines]: https://docs.gitlab.com/ee/development/code_review.html#approval-guidelines
[Canonical repository]: https://gitlab.com/gitlab-org/gitlab
[`package-and-qa` build]: https://docs.gitlab.com/ee/development/testing_guide/end_to_end/#using-the-package-and-qa-job
