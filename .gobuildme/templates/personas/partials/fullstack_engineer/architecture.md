## Fullstack Engineer-Specific Architecture Documentation

As a **Fullstack Engineer**, your focus is on documenting the complete end-to-end architecture from data model through API to user interface, ensuring seamless integration across all layers.

### Full-Stack Architecture Overview

**Required**: Document the complete system architecture in `.gobuildme/docs/technical/architecture/`

Include:
- **System Boundaries**: How frontend, backend, and data layers interact
- **Integration Points**: How components communicate across the stack
- **Data Flow**: End-to-end request/response cycles from UI to database
- **Technology Stack**: Frontend frameworks, backend services, databases, infrastructure
- **Deployment Architecture**: How the full stack is deployed and scaled

### API Architecture & Integration

**Required**: Document API design and client integration in `.gobuildme/docs/technical/architecture/patterns/api-design.md`

Include:
- **API Style**: REST, GraphQL, gRPC, or hybrid approach
- **Client Integration**: How frontend consumes APIs (fetch, axios, React Query, Apollo)
- **Versioning Strategy**: API versioning and client compatibility
- **Authentication Flow**: End-to-end auth from UI to backend
- **Authorization**: How UI enforces permissions before API calls
- **Error Handling**: Standard error response format and UI error display strategy
- **Rate Limiting**: How rate limits are communicated to UI
- **Caching Strategy**: API response caching on client and server
- **Optimistic Updates**: When and how UI updates before server confirmation
- **API Documentation**: OpenAPI/GraphQL schema for frontend consumption

### Database & Data Model Architecture

**Required**: Document database design in `.gobuildme/docs/technical/architecture/patterns/database.md`

Include:
- **Database Type**: SQL, NoSQL, or polyglot persistence
- **Schema Design**: Entity relationships, normalization level
- **Indexing Strategy**: Indexes for common query patterns
- **Migrations & UI Impact**: How schema changes affect UI components
- **UI Fallbacks**: How UI handles data model transitions during migration
- **Transactions**: Transaction boundaries and UI feedback during long operations
- **Data Validation**: Server-side and client-side validation strategies
- **Backup and Recovery**: RTO/RPO and user communication during recovery

### Frontend Component Architecture

**Required**: Document component structure in `.gobuildme/docs/technical/architecture/patterns/frontend-components.md`

Include:
- **Component Framework**: React, Vue, Angular, Svelte, or other
- **Component Hierarchy**: How components are organized
- **Component Types**: Presentational vs. container vs. API-connected components
- **Data-Fetching Components**: How components interact with backend APIs
- **Props and Events**: Data flow from API responses to component props
- **Reusable Components**: Shared component library
- **Component Testing**: Testing strategies for components with API dependencies

### State Management & API Integration

**Required**: Document state management approach

Include:
- **State Management Library**: Redux, MobX, Zustand, Context API, React Query, SWR, or other
- **State Structure**: How application state mirrors backend data models
- **API State Management**: How API responses update state
- **Cache Management**: How client-side caches sync with backend
- **State Persistence**: Local storage coordination with backend sessions
- **Optimistic Updates**: When to update UI before server confirmation
- **Error Recovery**: How state recovers from failed API calls
- **State Debugging**: DevTools for debugging full-stack state flow

### Routing & Navigation

**Required**: Document routing architecture

Include:
- **Router Library**: React Router, Vue Router, or other
- **Route Structure**: URL patterns mapping to API resources
- **Deep Linking**: How deep links relate to backend resources
- **Authentication Guards**: Route-level auth checking before API calls
- **Lazy Loading**: Code splitting strategy coordinated with API data prefetching
- **Navigation Patterns**: Breadcrumbs, tabs, wizards with backend state

### UI/UX Patterns & Design System

**Required**: Document UI patterns in alignment with backend capabilities

Include:
- **Design System**: Component library, design tokens
- **Loading States**: Skeleton screens, spinners for API calls
- **Error States**: How API errors are displayed to users
- **Empty States**: How UI handles empty API responses
- **Accessibility**: ARIA labels, keyboard navigation, screen readers
- **Internationalization**: i18n approach coordinated with backend localization
- **Responsive Design**: Layouts across devices with API data

### Performance Optimization (Full-Stack)

**Required**: Document end-to-end performance strategies

Include:
- **Backend Performance**:
  - API response time budgets (e.g., p95 < 200ms)
  - Database query optimization
  - Caching layers (Redis, CDN)
  - Background job processing
- **Frontend Performance**:
  - Core Web Vitals targets (LCP, FID, CLS)
  - Code splitting and lazy loading
  - Image optimization
  - Bundle size budgets
- **Integration Performance**:
  - Prefetching strategies
  - Request batching and deduplication
  - Server-side rendering or static generation
  - Progressive enhancement

### Observability (Full-Stack)

**Required**: Document end-to-end observability

Include:
- **Backend Observability**:
  - Metrics: Request rates, latencies, error rates
  - Logging: Structured logs with correlation IDs
  - Tracing: Distributed tracing across services
- **Frontend Observability**:
  - Real User Monitoring (RUM)
  - Error tracking (Sentry, Rollbar)
  - Performance monitoring
  - User session recording
- **Integration Observability**:
  - Correlation between frontend errors and backend failures
  - End-to-end transaction tracing (UI click → API → DB → response → UI update)
  - Alerting on user-impacting issues

### Security Architecture (Full-Stack)

**Required**: Document comprehensive security measures

Include:
- **Frontend Security**:
  - XSS prevention (Content Security Policy)
  - CSRF protection
  - Sensitive data handling (no tokens in localStorage without encryption)
  - Third-party script management
- **Backend Security**:
  - Input validation and sanitization
  - SQL injection prevention
  - Authentication and authorization
  - Secrets management
  - API rate limiting
- **Integration Security**:
  - Secure token transmission
  - Session management
  - HTTPS enforcement
  - CORS configuration

### Build, Deployment & CI/CD

**Required**: Document full-stack build and deployment

Include:
- **Build Process**:
  - Frontend build tool (Webpack, Vite, Parcel)
  - Backend build process
  - Environment configuration management
  - Asset compilation and optimization
- **Deployment Strategy**:
  - Deployment sequence (backend first, then frontend, or atomic)
  - Database migration timing
  - Feature flags for gradual rollout
  - Rollback strategy for full-stack changes
- **CI/CD Pipeline**:
  - Test stages (frontend, backend, integration, E2E)
  - Deployment gates
  - Environment promotion strategy

### Fullstack Engineer Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **Full-Stack Data Flow**: Complete request/response cycles documented
- [ ] **API Design**: REST/GraphQL patterns and client integration documented
- [ ] **Database Schema**: Entity relationships and UI impact of migrations
- [ ] **Component Architecture**: Component hierarchy and API integration patterns
- [ ] **State Management**: How state syncs with backend data models
- [ ] **Routing**: URL structure mapping to backend resources
- [ ] **Performance (Both Layers)**: Frontend and backend optimization strategies
- [ ] **Observability (Both Layers)**: End-to-end monitoring and correlation
- [ ] **Security (Both Layers)**: Frontend and backend security measures
- [ ] **Build & Deployment**: Full-stack deployment strategy and rollback plan
- [ ] **Error Handling**: How errors propagate from backend to UI
- [ ] **Testing Strategy**: Unit, integration, E2E testing approach
