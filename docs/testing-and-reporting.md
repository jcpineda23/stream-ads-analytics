# Testing And Reporting Strategy

## Purpose
This project is not only about building a streaming system. It is also about building the kind of evidence, reasoning, and tradeoff narrative that helps in a system design interview.

For that reason, every milestone should produce:
- implementation artifacts,
- test evidence,
- a short report describing what happened,
- a short reflection describing what was learned.

## What To Record
For each milestone or major experiment, record four things:

### 1. Setup
- what code or configuration was under test
- what services were running
- what input parameters were used
- what assumptions were being tested

### 2. Procedure
- exact commands run
- sequence of actions taken
- whether the run was manual or scripted

### 3. Outcome
- pass or fail
- notable metrics or observations
- errors, bottlenecks, or unexpected behavior

### 4. Interpretation
- what the result means for the architecture
- what tradeoff or design lesson it demonstrates
- what should change next

## Why This Matters For Interviews
Interviewers care less about whether a side project is "finished" and more about whether you can explain:
- why you designed it that way
- what failed first
- how you validated assumptions
- what tradeoffs you discovered under load
- what you would change in a production version

This means the evidence trail is part of the portfolio.

## Repository Structure
Use this structure for durable evidence:

```text
evidence/
  README.md
  templates/
    test-run-template.md
    milestone-report-template.md
  phase-1/
    README.md
  phase-2/
    README.md
  phase-3/
    README.md
  phase-4/
    README.md
  phase-5/
    README.md
  phase-6/
    README.md
```

## Two Artifact Types
### Test run records
Use these for individual executions:
- smoke test runs
- producer validation runs
- duplicate or late-event experiments
- throughput tests
- replay tests

These should be short and factual.

### Milestone reports
Use these for the summary at the end of a milestone:
- what was built
- what was validated
- what risks remain
- what design lessons were learned

These should be more narrative and interview-friendly.

## Naming Convention
Use stable, sortable filenames:

### Test runs
`YYYY-MM-DD-<phase>-<short-name>.md`

Examples:
- `2026-05-03-phase-1-smoke-test.md`
- `2026-05-10-phase-2-low-rate-producer.md`
- `2026-05-12-phase-2-hot-campaign-skew.md`

### Milestone reports
`YYYY-MM-DD-<phase>-milestone-<n>-report.md`

Examples:
- `2026-05-03-phase-1-milestone-3-report.md`
- `2026-05-15-phase-2-milestone-2-report.md`

## What Belongs In Git
Commit:
- markdown summaries
- commands run
- key screenshots if they add real value
- compact logs or excerpts
- result tables

Do not commit:
- huge raw logs
- generated binary dumps
- secrets
- local-only `.env` files

If a raw log is too large, summarize it in markdown and quote only the important lines.

## Recommended Workflow Per Milestone
1. define the hypothesis
2. run the test
3. record the command and result
4. summarize the lesson
5. update the milestone report

This keeps the repo useful both as:
- a build log for yourself
- a storytelling asset for interviews

## Minimum Standard For Each Phase
Every phase should end with:
- at least one test run record
- one milestone report
- one short section called `Design Lessons`

## Suggested Design Lessons Format
Capture lessons in this shape:
- `What we expected`
- `What actually happened`
- `What this tells us about the architecture`
- `What we would change in production`

This is the exact kind of reflection that makes interview answers feel senior rather than academic.
