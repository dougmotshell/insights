<!-- TEMPLATE — copy to container-<system-slug>.md and fill in. Delete these comments when done. -->
# Container Diagram — \<System Name\>

**Level:** 2 — Container
**Owner:** \<team/person\>
**Last updated:** \<YYYY-MM-DD\>

One paragraph: the applications/services/stores inside the system boundary and how they fit together.

```mermaid
C4Container
    title Container diagram for <System Name>

    Person(user, "User", "A user of the system")

    System_Boundary(system, "<System Name>") {
        Container(webApp, "Web Application", "e.g. React/Next.js", "Delivers the UI")
        Container(api, "API", "e.g. Node/Go/Python", "Serves business logic over HTTP/gRPC")
        ContainerDb(db, "Database", "e.g. Postgres", "Stores <what>")
    }

    System_Ext(extSystem, "External System", "What it provides")

    Rel(user, webApp, "Uses", "HTTPS")
    Rel(webApp, api, "Calls", "JSON/HTTPS")
    Rel(api, db, "Reads from / writes to", "SQL")
    Rel(api, extSystem, "Calls", "HTTPS")
```

## Notes

- Call out anything relevant to how containers actually run: deployment target, scaling model, sync vs async communication.
