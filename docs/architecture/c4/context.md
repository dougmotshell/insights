<!-- TEMPLATE — copy to context-<system-slug>.md and fill in. Delete these comments when done. -->
# Context Diagram — \<System Name\>

**Level:** 1 — System Context
**Owner:** \<team/person\>
**Last updated:** \<YYYY-MM-DD\>

One paragraph: what this system does and for whom.

```mermaid
C4Context
    title System Context diagram for <System Name>

    Person(user, "User", "A user of the system")
    System(system, "<System Name>", "What this system does, in one line")
    System_Ext(extSystem, "External System", "What it provides to <System Name>")

    Rel(user, system, "Uses")
    Rel(system, extSystem, "Calls / reads from / sends to")
```

## Notes

- List anything the diagram can't show: authentication method with each external system, SLAs, data classification, etc.
