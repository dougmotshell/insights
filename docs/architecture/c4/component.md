<!-- TEMPLATE — copy to component-<container-slug>.md and fill in. Delete these comments when done. -->
# Component Diagram — \<Container Name\>

**Level:** 3 — Component
**Owner:** \<team/person\>
**Last updated:** \<YYYY-MM-DD\>

One paragraph: the internal building blocks of this container and their responsibilities.

```mermaid
C4Component
    title Component diagram for <Container Name>

    Container_Boundary(container, "<Container Name>") {
        Component(controller, "Controller", "e.g. HTTP handler", "Accepts requests, validates input")
        Component(service, "Service", "e.g. domain logic", "Implements <business rule>")
        Component(repo, "Repository", "e.g. data access", "Reads/writes <entity>")
    }

    ContainerDb_Ext(db, "Database", "e.g. Postgres", "Stores <what>")

    Rel(controller, service, "Calls")
    Rel(service, repo, "Calls")
    Rel(repo, db, "Reads from / writes to", "SQL")
```

## Notes

- Document non-obvious internal contracts: idempotency, retries, invariants a component relies on.
