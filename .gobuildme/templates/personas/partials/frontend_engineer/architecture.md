## Frontend Engineer-Specific Architecture Documentation

As a **Frontend Engineer**, your focus is on documenting the frontend architecture, component design, state management, and user experience patterns.

### Component Architecture

**Required**: Document component structure in `.gobuildme/docs/technical/architecture/patterns/frontend-components.md`

Include:
- **Component Framework**: React, Vue, Angular, Svelte, or other
- **Component Hierarchy**: How components are organized
- **Component Types**: Presentational vs. container components
- **Component Composition**: How components are composed
- **Props and Events**: Data flow patterns
- **Component Lifecycle**: Lifecycle management patterns
- **Reusable Components**: Shared component library
- **Component Testing**: Testing strategies for components

### State Management

**Required**: Document state management approach

Include:
- **State Management Library**: Redux, MobX, Zustand, Context API, or other
- **State Structure**: How application state is organized
- **State Updates**: How state changes are triggered
- **Side Effects**: How async operations are handled
- **State Persistence**: Local storage, session storage strategies
- **State Synchronization**: How state syncs with backend
- **Derived State**: Computed values and selectors
- **State Debugging**: DevTools and debugging strategies

### Routing and Navigation

**Required**: Document routing architecture

Include:
- **Router Library**: React Router, Vue Router, or other
- **Route Structure**: URL patterns and route hierarchy
- **Route Guards**: Authentication and authorization checks
- **Lazy Loading**: Code splitting and lazy route loading
- **Deep Linking**: How deep links are handled
- **Navigation Patterns**: Breadcrumbs, tabs, wizards
- **History Management**: Browser history handling

### UI/UX Patterns

**Required**: Document UI patterns and design system

Include:
- **Design System**: Component library, design tokens
- **Layout Patterns**: Grid systems, responsive layouts
- **Typography**: Font scales, text styles
- **Color Palette**: Color schemes and usage
- **Spacing System**: Margin and padding scales
- **Animation**: Animation patterns and transitions
- **Accessibility**: ARIA labels, keyboard navigation, screen readers
- **Internationalization**: i18n approach and locale management

### Data Fetching and Caching

**Required**: Document data fetching patterns

Include:
- **Data Fetching Library**: React Query, SWR, Apollo, or fetch/axios
- **API Integration**: How frontend calls backend APIs
- **Caching Strategy**: Client-side caching approach
- **Optimistic Updates**: How UI updates before server confirmation
- **Error Handling**: How API errors are displayed
- **Loading States**: Loading indicators and skeletons
- **Retry Logic**: How failed requests are retried
- **Offline Support**: Progressive Web App features if applicable

### Performance Optimization

**Required**: Document frontend performance strategies

Include:
- **Code Splitting**: How bundles are split
- **Lazy Loading**: Component and route lazy loading
- **Image Optimization**: Image formats, lazy loading, responsive images
- **Bundle Size**: Bundle analysis and optimization
- **Caching**: Browser caching, service workers
- **Rendering Optimization**: Virtual scrolling, memoization
- **Performance Monitoring**: Core Web Vitals, performance metrics
- **Build Optimization**: Minification, tree shaking, compression

### Build and Deployment

**Required**: Document frontend build process

Include:
- **Build Tool**: Webpack, Vite, Parcel, or other
- **Build Configuration**: Development vs. production builds
- **Environment Variables**: How environment config is managed
- **Asset Management**: How static assets are handled
- **CDN Strategy**: How assets are served
- **Deployment Process**: How frontend is deployed
- **Versioning**: How frontend versions are managed
- **Rollback Strategy**: How to rollback deployments

### Security Considerations

**Required**: Document frontend security measures

Include:
- **XSS Prevention**: How cross-site scripting is prevented
- **CSRF Protection**: Cross-site request forgery protection
- **Content Security Policy**: CSP headers and configuration
- **Authentication**: How auth tokens are stored and used
- **Sensitive Data**: How sensitive data is handled in frontend
- **Third-Party Scripts**: How external scripts are managed
- **Dependency Security**: How dependencies are audited

### Frontend Engineer Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **Component Structure**: Component hierarchy and patterns documented
- [ ] **State Management**: State architecture and flow documented
- [ ] **Routing**: Navigation and routing patterns documented
- [ ] **Design System**: UI patterns and design tokens documented
- [ ] **Data Fetching**: API integration and caching strategy documented
- [ ] **Performance**: Optimization strategies documented
- [ ] **Build Process**: Build and deployment process documented
- [ ] **Security**: Frontend security measures documented
- [ ] **Accessibility**: A11y patterns and requirements documented
- [ ] **Testing**: Frontend testing strategies documented

