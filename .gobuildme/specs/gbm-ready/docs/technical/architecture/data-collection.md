# Raw Architecture Data Collection (Existing Codebase)

**IMPORTANT**: This is RAW DATA ONLY - AI Agent must create actual architecture documentation
**Purpose**: Data collection for AI Agent to analyze and generate comprehensive architecture documentation
**Codebase Status**: Existing code detected - AI Agent should run /architecture command for global analysis
**AI Action Required**: Create system-analysis.md, component-architecture.md, and other architecture docs

## Project Structure Data
```json
{
  "directories": [
    ".",
    "support_docs",
    "support_docs/slides",
    "support_docs/pdfs",
    "support_docs/cheatsheets",
    ".claude",
    ".claude/commands",
    "packages",
    "packages/database",
    "packages/server",
    "packages/server/middleware",
    "packages/server/models",
    "packages/server/db",
    "packages/server/routes",
    "packages/client",
    "packages/client/node_modules",
    "packages/client/public",
    "packages/client/src"
  ],
  "config_files": [
    "package.json"
    ""
  ],
  "framework_indicators": [
    
  ]
}
```

## Technology Stack Indicators
```json
{
  "languages": {
    "php":        1,
    "javascript":     4000,
    "python":        2,
    "total": 0
  },
  "database_indicators": [
    
  ],
  "infrastructure_indicators": [
    
  ]
}
```

## Architectural Pattern Indicators
```json
{
  "mvc_indicators": {
    "models_dir": false,
    "views_dir": false,
    "controllers_dir": false
  },
  "microservices_indicators": {
    "docker_compose": false,
    "dockerfile": false,
    "kubernetes": false,
    "services_dir": false
  },
  "api_patterns": [
    "versioned_api","graphql","rest_api"
  ],
  "event_driven_indicators": [
    "events","listeners","queues","observers"
  ]
}
```

## Security & Integration Indicators
```json
{
  "authentication_indicators": [
    "jwt","session"
  ],
  "authorization_indicators": [
    "roles","permissions","policies","middleware"
  ],
  "external_service_indicators": [
    
  ]
}
```

## Data Collection Summary
```json
{
  "collection_metadata": {
    "project_root": "/Users/codeshock/software/clients/gofundme/yes-fund-me/yesfundme",
    "analysis_version": "2.0",
    "data_collector": "GoBuildMe Architecture Data Collector"
  },
  "ai_agent_instructions": {
    "purpose": "Generate comprehensive architectural analysis from collected data",
    "focus": "High-level strategic architectural insights and system design understanding",
    "output_format": "Executive-level architectural documentation with business context",
    "analysis_areas": ["architectural_style", "technology_decisions", "component_relationships", "scalability_patterns", "security_architecture", "integration_landscape"]
  }
}
```

---
**Next Step**: This raw data should be analyzed by an AI Agent to generate comprehensive architectural insights and strategic recommendations.
