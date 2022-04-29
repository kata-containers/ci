# Introduction

We have occasionally seen that the CI fails due to unrellable tests or jobs, environment issues and more. This presents a challenge for new contributors as they need to spend time figuring out issues that are not related to their changes in the code. It also prevents the confidence the community has in the CI as a simple yes/no answer and instead talks about required compared with optional tests.

We believe that this will become an increasing bottleneck if the Kata community is successful in starting the new [confidential containers project](https://github.com/confidential-containers) which will bring in additional participating companies and individual contributors. Given this, we established a process and policy that should allow the project to maintain a "Always Green CI" aiming to improve the results of Kata Containers CI shown in GitHub.

# Concepts

In this section we discuss the main pillars that sustain the "Always Green CI" initiative.

## Baseline jobs

We have created multiple jobs (called "baselines") which run on a daily basis for the different test suites and configuration/HW which are identical to what will run on each pull request (PR). The key point is that this CI runs on a branch with no additional patches/noise added by anyone so if there is a failure it’s much easier to identify it. The baseline jobs indicate the overall status of the Kata Containers project and our aim is to ensure they always pass (so the "always green" name). They are used as a base for comparing with the CI jobs ran on each pull request (PR): if a given CI job fails but its corresponding on baseline is "green" then it is likely the code change breaking tests.

Each and every baseline CI job **must have** owners monitoring it’s status and acting if something goes wrong. Policies and a process to add/remove jobs to/from the baseline were defined.

Find the complete list of baseline jobs [here](http://jenkins.katacontainers.io/view/Daily%20baseline/).

## CI jobs

Those are the jobs which will run on each pull request (PR). They are identical to baseline jobs, except that they test code changes proposed by the developers (the baseline jobs will test merged code). If a given CI job fails but its corresponding on baseline is "green" then it is likely the code change broke tests. So each and every CI job **must have** a counterpart baseline job.

The CI job is configured to be either:

 * required: meaning the job must pass for the PR be merged. This is reserved for jobs we are confident about their stability;
 * non-required: its failure won't block the PR. This is reserved for jobs which are still unstable or/and experimental.

The CI job is promoted to required if it has a proven record of stability over a period of time. Likewise it can be demoted to non-required in case it turned unstable. See the [guidelines section](#guidelines) on this document for further information about the policies and procedures to move a job from required to non-required (and vice-versa).

Find the complete list of CI jobs [here](http://jenkins.katacontainers.io/view/PR%20Triggered/).

## Owners of jobs

Each and every baseline job **must have** a owner who is committed to maintain the stability of the job. Having co-owners working from different difficulties to pass their PR on the CI jobs.

# Guidelines

## When to remove a job or add it back to the baseline list and CI?

 * A baseline job is entitled for CI after five consecutive successes
 * A job is marked non-required in the CI after two consecutive failures of its corresponding baseline job
 * A job is removed from the baseline list after 15 consecutive failures
 * A job can be marked back to required in the CI after two consecutive successes of its corresponding baseline job

## What to do when a CI job fails?

 * If the job fails on the CI however passed on the daily baseline it is the developer's responsibility to solve the problem
 * If the job also fails on the daily baseline the developer can proceed to pushing the PR by contacting the relevant people

## Who are responsible for adding/removing/debugging jobs in the baseline list and CI?

 * If the CI job failed **and** its corresponding baseline is "red" then the developer should contact the baseline owner
 * The following groups can be contacted in the case of the CI job be moved to require/non-required:
   * `Architecture Committee` (AC) (@kata-containers/architecture-committee)
   * `Kata CI Team` (@kata-containers/ci)

The job owner should also be notified to debug any issue and `Ariel Adam` (`@ariel-adam`) should be notified to follow up with the job owners. See the list of job owners [here](http://jenkins.katacontainers.io/view/Daily%20baseline).
