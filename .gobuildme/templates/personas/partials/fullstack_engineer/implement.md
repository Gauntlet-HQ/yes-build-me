### Persona-Specific Implementation Guidance — Fullstack Engineer

Implementation best practices for fullstack development:

**API-First Development**:
- Define and validate API contracts before UI implementation
- Use OpenAPI/GraphQL schemas as source of truth
- Generate TypeScript types from backend schemas
- Test APIs independently before integrating with UI

**Component-API Integration Patterns**:
- Separate data-fetching logic from presentation components
- Use custom hooks (React) or composables (Vue) for API calls
- Implement proper loading, error, and success states in every component
- Cache API responses appropriately (React Query, SWR, or custom caching)

**Error Handling Across Layers**:
- Backend: Return consistent error structures (code, message, details)
- Frontend: Map error codes to user-friendly messages
- Display errors contextually (inline validation vs. global toast/banner)
- Log errors with correlation IDs for end-to-end debugging

**State Management Integration**:
- Colocate state close to where it's used
- Lift state only when necessary for sharing across components
- Sync backend state with UI state using proper cache invalidation
- Handle optimistic updates with rollback on API failures

**Performance Considerations**:
- Lazy load routes and components
- Prefetch data for anticipated user actions
- Implement pagination/infinite scroll for large datasets
- Optimize images and assets with appropriate formats and lazy loading
- Use request batching to reduce API call overhead

**Observability Integration**:
- Add structured logging with correlation IDs (UUIDs) at both layers
- Instrument API calls with timing metrics
- Track user interactions in frontend (analytics, error tracking)
- Set up distributed tracing from UI click to database query

**Database Migration Coordination**:
- Plan backend schema changes with UI compatibility in mind
- Implement feature flags to toggle new data model usage
- Deploy migrations with backwards-compatible API changes first
- Update UI after migration completes and stabilizes
- Maintain rollback plan for both database and UI changes

**Testing Strategy**:
- Write API tests before implementation (TDD)
- Mock API responses for isolated component testing
- Use integration tests for critical user paths
- Validate error handling with synthetic failures
- Run E2E tests for complete workflows

**Security Practices**:
- Never trust client-side validation alone - always validate on backend
- Sanitize user inputs on both frontend and backend
- Store sensitive data (tokens) securely, prefer HTTP-only cookies
- Implement proper CORS configuration
- Use Content Security Policy headers
- Audit third-party dependencies regularly

**Deployment Coordination**:
- Deploy database migrations first (with backwards compatibility)
- Deploy backend changes second (supporting old and new data models temporarily)
- Deploy frontend changes last (using new APIs/data model)
- Use feature flags to control rollout and enable rollback
- Monitor error rates and performance metrics after each deployment phase

**Documentation**:
- Keep API documentation (OpenAPI/GraphQL schema) up to date
- Document component props and expected API response shapes
- Maintain README with local development setup for full stack
- Document environment variables needed for both frontend and backend
- Create runbooks for common operational tasks (deployments, rollbacks, migrations)
