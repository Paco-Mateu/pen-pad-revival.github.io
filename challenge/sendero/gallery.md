# Sendero screenshot walkthrough

[Return to the briefing](readme.md)

Screenshots supplied for the bonus-track submission, captured on 20 November 2026. The English-interface captures below document the prototype, including empty and no-match states. Synthetic evidence is illustrative. The individual shown is a demonstration identifier; this gallery is not a release of patient-level source exports.

## Select a person

Identifier-based selection and entry into an encounter. The screenshot shows the demonstration list, not the size of the underlying NAVETA cohort.

![Select a person](screenshots/01-patient-list.png)

## History and PROM workspace

This capture explicitly has no historical sources loaded and no repeated numeric series. It shows the empty state, not imported longitudinal clinical evidence.

![History and PROM workspace](screenshots/02-history-and-proms.png)

## Target a concern

A broad opening question and answer buttons coexist with access to other assessment topics. Guided mode is optional.

![Target a concern](screenshots/03-guided-first-question.png)

## Relate a concern to evidence

A rest concern is shown beside a synthetic score-history card. Its illustrative values must not be interpreted as validated raw questionnaire item scores.

![Relate a concern to evidence](screenshots/04-evidence-and-follow-up.png)

## Refine the description

A sleep difficulty leads to duration and further details while preserving the developing account and the path into the question.

![Refine the description](screenshots/05-deeper-pathway.png)

## Offer answers without supplying them

Medication-taking options and descriptive response frequencies are visible. Frequencies describe the displayed aggregate; they are not a probability that this individual will give a particular answer.

![Offer answers without supplying them](screenshots/06-likely-answers-medication.png)

## Target by location

The physical-concern fragment supports body-region selection as another entry point into refinement.

![Target by location](screenshots/07-body-map.png)

## Confirm the intended account

The professional reviews the narrative and selected answers. The visible mapping-draft label is important: confirming this interview does not certify a native openEHR export.

![Confirm the intended account](screenshots/09-review-and-confirm.png)

## Keep evidence beside the interview

Synthetic evidence cards can be explored, deferred or marked irrelevant. No comparable pathways are returned in this capture.

![Keep evidence beside the interview](screenshots/10-evidence-similar-pathways.png)

## Represent missing hospital context explicitly

The hospital history view is empty in this capture. It does not demonstrate a live connection to medication, admission or laboratory systems.

![Represent missing hospital context explicitly](screenshots/11-clinical-record.png)

## Browse the concept hierarchy

The layered graph displays general-to-specific paths and multiple inheritance in the authored assessment taxonomy. It is not a complete medical terminology.

![Browse the concept hierarchy](screenshots/12-ontology-graph.png)

## Inspect a selected concept

The inspector connects an assessment type to its parents, children and reusable fragments.

![Inspect a selected concept](screenshots/13-ontology-node-detail.png)

## Separate hierarchy from mappings

Optional layers expose fragments and source or record bindings. These relations are distinct from subtype relationships.

![Separate hierarchy from mappings](screenshots/13b-ontology-with-layers.png)

## Search candidate evidence

The evidence-search controls are shown before results. This capture uses the local words-and-concepts mode and does not itself demonstrate Atlas/Voyage retrieval.

![Search candidate evidence](screenshots/14-research-pathways.png)

## Show a no-match result honestly

The pathway view reports zero eligible matches in the displayed comparison. It demonstrates the no-match state, not a successful discovery or a clinical outcome prediction.

![Show a no-match result honestly](screenshots/14b-research-similar-pathways.png)
