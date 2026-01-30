### Persona-Specific Implementation Guidance — Frontend Engineer

Implementation best practices for frontend development:

**Component Architecture**:
- Design components with single responsibility principle
- Create reusable, composable components
- Use proper component hierarchy (container/presentational pattern)
- Implement proper prop typing with TypeScript or PropTypes
- Keep components small and focused (< 300 lines)
- Extract custom hooks/composables for reusable logic
- Follow established component naming conventions

**State Management**:
- Choose appropriate state management (local, context, global store)
- Colocate state close to where it's used
- Lift state only when necessary for sharing
- Use state management libraries appropriately (Redux, Zustand, Pinia)
- Implement proper state normalization for complex data
- Handle loading, error, and success states consistently
- Optimize re-renders with memoization (useMemo, React.memo)

**Data Fetching & API Integration**:
- Use data fetching libraries (React Query, SWR, Apollo)
- Implement proper loading states and skeletons
- Handle errors gracefully with user-friendly messages
- Cache API responses to reduce network requests
- Implement optimistic updates for better UX
- Add request deduplication for simultaneous requests
- Use proper TypeScript types for API responses

**Responsive Design**:
- Implement mobile-first responsive layouts
- Use CSS Grid and Flexbox for modern layouts
- Test across multiple screen sizes (mobile, tablet, desktop)
- Use appropriate breakpoints (360px, 768px, 1024px, 1440px)
- Implement responsive images with srcset/picture elements
- Test on actual devices, not just browser dev tools
- Handle touch interactions properly on mobile

**Accessibility (WCAG 2.1 AA)**:
- Use semantic HTML elements (nav, main, article, section)
- Implement proper heading hierarchy (h1-h6)
- Add ARIA labels and roles where needed
- Ensure keyboard navigation works for all interactive elements
- Maintain minimum contrast ratios (4.5:1 for text)
- Provide alt text for all images
- Test with screen readers (NVDA, JAWS, VoiceOver)
- Ensure focus indicators are visible
- Implement skip navigation links

**Performance Optimization**:
- Lazy load routes and components
- Implement code splitting for route-based chunks
- Optimize bundle size (analyze with webpack-bundle-analyzer)
- Use proper image formats and compression (WebP, AVIF)
- Implement lazy loading for images and videos
- Prefetch critical resources with link rel="prefetch"
- Minimize JavaScript execution time
- Implement virtual scrolling for long lists
- Optimize web vitals (LCP, FID, CLS, INP)

**Form Handling & Validation**:
- Use form libraries (React Hook Form, Formik, VeeValidate)
- Implement client-side validation with clear error messages
- Show validation errors inline near form fields
- Handle server-side validation errors properly
- Implement proper submit button states (loading, disabled)
- Preserve form state on navigation (if appropriate)
- Implement proper input masking and formatting
- Handle file uploads with progress indicators

**Error Handling & User Feedback**:
- Display loading states with appropriate UI (spinners, skeletons)
- Show error messages contextually (toast, banner, inline)
- Implement global error boundaries (React) or error handlers
- Handle network errors gracefully with retry options
- Provide user feedback for all actions (success, error, warning)
- Implement proper 404 and error pages
- Log errors to monitoring service (Sentry, Bugsnag)

**Routing & Navigation**:
- Implement proper routing (React Router, Vue Router, Next.js)
- Use proper navigation patterns (links vs. programmatic)
- Implement breadcrumbs for deep navigation structures
- Handle protected routes with proper redirects
- Preserve query parameters when needed
- Implement proper loading states during route transitions
- Use proper meta tags for SEO (title, description, Open Graph)

**Styling Implementation**:
- Choose appropriate styling approach (CSS Modules, Styled Components, Tailwind)
- Maintain consistent design system (colors, typography, spacing)
- Use CSS variables for theming
- Implement dark mode support
- Follow BEM or similar naming convention for vanilla CSS
- Keep styles scoped to components
- Optimize CSS bundle size
- Use CSS-in-JS with proper performance considerations

**Testing Strategy**:
- Write component tests with Testing Library
- Test user interactions, not implementation details
- Implement integration tests for critical user paths
- Use visual regression testing (Chromatic, Percy)
- Test accessibility with axe-core or similar tools
- Mock API responses for isolated component testing
- Test error states and edge cases
- Achieve minimum 85% code coverage

**Security Practices**:
- Sanitize user inputs to prevent XSS attacks
- Use Content Security Policy headers
- Validate data from APIs before rendering
- Store sensitive data (tokens) in HTTP-only cookies or secure storage
- Implement proper CORS handling
- Avoid exposing sensitive information in client-side code
- Audit third-party dependencies regularly with npm audit
- Use Subresource Integrity (SRI) for CDN resources

**Build & Deployment**:
- Optimize production builds (minification, tree-shaking)
- Use environment variables properly
- Implement proper caching strategies (service workers)
- Set up CI/CD for automated builds and deployments
- Implement proper asset versioning/cache busting
- Monitor build sizes and bundle analysis
- Use CDN for static assets
- Implement proper CSP and security headers

**Browser Compatibility**:
- Test on modern browsers (Chrome, Firefox, Safari, Edge)
- Use Browserslist to target appropriate browser versions
- Polyfill necessary features with appropriate strategies
- Test on actual browsers, not just simulators
- Handle browser-specific quirks gracefully
- Use feature detection instead of browser detection

**Documentation**:
- Document component APIs with PropTypes or TypeScript
- Maintain component storybook for design system
- Create README with setup and development instructions
- Document custom hooks and utility functions
- Maintain style guide and coding conventions
- Document browser support and known issues
