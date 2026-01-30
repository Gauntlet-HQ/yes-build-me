### Frontend Engineer Quality Dimensions

When validating frontend requirements and specifications, ensure these quality dimensions are addressed:

#### Component Architecture

**Component Structure**:
- Is component hierarchy documented?
- Are component responsibilities clearly defined?
- Is component reusability strategy specified?
- Are prop/state management patterns documented?

**Component Composition**:
- Is component composition pattern specified?
- Are render prop/HOC/hooks patterns documented?
- Is children composition strategy defined?
- Are component slots/portals usage specified?

**Component Organization**:
- Is folder structure convention documented?
- Are naming conventions clearly defined?
- Is component co-location strategy specified?
- Are barrel exports strategy documented?

#### State Management

**State Architecture**:
- Is state management solution specified (Context, Redux, Zustand, Recoil)?
- Is state architecture pattern documented (flux, atomic)?
- Are state slicing/normalization requirements defined?
- Is derived state strategy specified?

**Global vs. Local State**:
- Is global state scope clearly defined?
- Are local state management patterns documented?
- Is state lifting strategy specified?
- Are prop drilling mitigation strategies defined?

**State Persistence**:
- Is state persistence strategy specified?
- Are persistence targets documented (localStorage, sessionStorage)?
- Is state hydration strategy defined?
- Are state migration requirements specified?

**Async State Management**:
- Is async state handling pattern specified?
- Are loading/error state management strategies documented?
- Is cache invalidation strategy defined?
- Are optimistic updates requirements specified?

#### UI/UX Design Implementation

**Visual Design Specifications**:
- Are color palette values specified (hex, rgb, hsl)?
- Is typography system documented (font families, sizes, weights)?
- Are spacing values defined (margin, padding scale)?
- Are border radius values specified?

**Responsive Design**:
- Are breakpoints clearly defined (mobile, tablet, desktop)?
- Is mobile-first approach documented?
- Are responsive layout strategies specified (flexbox, grid)?
- Are viewport-specific behavior requirements defined?

**Design System Integration**:
- Is design system/component library specified (Material-UI, Chakra)?
- Are design tokens documented?
- Is theme configuration specified?
- Are custom component styling requirements defined?

**Accessibility (a11y)**:
- Are WCAG compliance level requirements specified (A, AA, AAA)?
- Is keyboard navigation strategy documented?
- Are ARIA attributes requirements defined?
- Is screen reader compatibility strategy specified?

#### User Interactions

**Event Handling**:
- Are event handling patterns documented?
- Is event delegation strategy specified?
- Are synthetic event requirements defined?
- Is event bubbling/capturing strategy documented?

**Form Handling**:
- Is form management solution specified (React Hook Form, Formik)?
- Are validation strategies documented?
- Is error message display strategy defined?
- Are form submission patterns specified?

**User Feedback**:
- Are loading indicators specified for all async operations?
- Is error boundary strategy documented?
- Are success/error notification patterns defined?
- Is skeleton/placeholder UI strategy specified?

**Animations & Transitions**:
- Are animation library requirements specified (Framer Motion, Spring)?
- Is animation duration/easing documented?
- Are transition states defined (enter, exit, active)?
- Is motion accessibility strategy specified (prefers-reduced-motion)?

#### Routing & Navigation

**Routing Strategy**:
- Is routing library specified (React Router, Next.js)?
- Are route structure and naming conventions documented?
- Is nested routing strategy defined?
- Are route guards/middleware requirements specified?

**Navigation Patterns**:
- Is navigation component architecture documented?
- Are active link styling requirements specified?
- Is breadcrumb navigation strategy defined?
- Are tab navigation patterns documented?

**URL Management**:
- Is query parameter handling strategy specified?
- Are URL state synchronization requirements documented?
- Is hash routing strategy defined?
- Is URL history management pattern specified?

**Code Splitting**:
- Is route-based code splitting strategy specified?
- Are dynamic import requirements documented?
- Is lazy loading strategy defined?
- Are loading fallback component requirements specified?

#### API Integration

**API Communication**:
- Is HTTP client library specified (axios, fetch)?
- Are API base URL configuration requirements documented?
- Is request/response interceptor strategy defined?
- Are retry logic requirements specified?

**Data Fetching**:
- Is data fetching library specified (React Query, SWR, Apollo)?
- Are caching strategies documented?
- Is refetch/revalidation strategy defined?
- Are pagination patterns specified?

**Error Handling**:
- Is API error handling strategy documented?
- Are error response format expectations specified?
- Is error display/notification strategy defined?
- Are error recovery patterns documented?

**Authentication**:
- Is token storage strategy specified?
- Are authentication header requirements documented?
- Is token refresh strategy defined?
- Is authenticated route protection pattern specified?

#### Performance Optimization

**Rendering Optimization**:
- Are memoization requirements specified (React.memo, useMemo)?
- Is virtualization strategy documented for long lists?
- Are callback optimization patterns defined (useCallback)?
- Is component lazy loading strategy specified?

**Bundle Optimization**:
- Are bundle size targets specified?
- Is tree shaking strategy documented?
- Are dynamic imports requirements defined?
- Is code splitting strategy specified?

**Asset Optimization**:
- Is image optimization strategy specified?
- Are lazy loading requirements for images/videos documented?
- Is CDN usage strategy defined?
- Are asset compression requirements specified?

**Web Vitals**:
- Are Core Web Vitals targets specified (LCP, FID, CLS)?
- Is performance monitoring strategy documented?
- Are performance budgets defined?
- Is performance regression detection strategy specified?

#### Browser Compatibility

**Browser Support**:
- Are supported browsers and versions specified?
- Is polyfill strategy documented?
- Are progressive enhancement requirements defined?
- Is graceful degradation strategy specified?

**Feature Detection**:
- Is feature detection strategy specified?
- Are fallback implementations documented?
- Is vendor prefix strategy defined?
- Are compatibility testing requirements specified?

**Cross-Browser Testing**:
- Is cross-browser testing strategy documented?
- Are testing tools specified (BrowserStack, Sauce Labs)?
- Is browser-specific bug handling strategy defined?
- Are compatibility issue resolution procedures specified?

#### Testing Strategy

**Unit Testing**:
- Is unit testing framework specified (Jest, Vitest)?
- Are component testing patterns documented?
- Is test coverage target specified?
- Are snapshot testing requirements defined?

**Integration Testing**:
- Is integration testing strategy specified?
- Are user flow testing requirements documented?
- Is mock strategy for external dependencies defined?
- Are integration test patterns specified?

**End-to-End Testing**:
- Is E2E testing framework specified (Playwright, Cypress)?
- Are critical user flow scenarios documented?
- Is E2E test data management strategy defined?
- Are E2E test execution requirements specified?

**Visual Regression Testing**:
- Is visual regression testing strategy specified?
- Are visual comparison tools documented (Percy, Chromatic)?
- Is snapshot approval workflow defined?
- Are visual regression test coverage requirements specified?

#### Build & Deployment

**Build Configuration**:
- Is build tool specified (Vite, Webpack, esbuild)?
- Are build optimization requirements documented?
- Is environment variable strategy defined?
- Are build artifact requirements specified?

**Development Environment**:
- Is dev server configuration documented?
- Are hot module replacement requirements specified?
- Is proxy configuration strategy defined?
- Are development tool requirements documented?

**Production Build**:
- Are production optimization requirements specified?
- Is minification strategy documented?
- Are source map requirements defined?
- Is build output validation strategy specified?

**Deployment Strategy**:
- Is deployment target specified (CDN, static hosting, SSR)?
- Are deployment automation requirements documented?
- Is cache invalidation strategy defined?
- Are rollback procedures specified?

#### Developer Experience

**Code Quality**:
- Is linting configuration specified (ESLint)?
- Are formatting rules documented (Prettier)?
- Is type checking strategy defined (TypeScript, PropTypes)?
- Are code review requirements specified?

**Development Tools**:
- Are required IDE extensions documented?
- Is debugging strategy specified?
- Are development scripts requirements defined?
- Are code generation tools specified?

**Documentation**:
- Is component documentation strategy specified (Storybook, Docusaurus)?
- Are prop documentation requirements defined?
- Is usage example documentation strategy specified?
- Are best practices documentation requirements defined?

#### Security

**Input Sanitization**:
- Is input sanitization strategy specified?
- Are XSS prevention measures documented?
- Is HTML/CSS injection prevention strategy defined?
- Are user-generated content handling requirements specified?

**Content Security Policy**:
- Is CSP configuration specified?
- Are trusted sources documented?
- Is inline script/style strategy defined?
- Are CSP violation reporting requirements specified?

**Dependency Security**:
- Is dependency vulnerability scanning strategy specified?
- Are dependency update policies documented?
- Is security advisory monitoring strategy defined?
- Are vulnerable dependency remediation requirements specified?

#### Accessibility Research & Evidence Quality

**WCAG Accessibility Claims** (Required Quality: A, 100%):
- Are WCAG 2.1/2.2 compliance level claims verified with w3.org official documentation?
- Are WCAG success criteria references citing current official W3C standards?
- Are accessibility technique recommendations verified with W3C technique documents?
- Are ARIA specification claims sourced from official w3.org/TR/wai-aria/?

**Accessibility Tool Claims** (Required Quality: B+, 85%+):
- Are screen reader compatibility claims verified with official documentation?
- Are accessibility testing tool capabilities backed by official tool documentation?
- Are accessibility audit results traceable to reputable sources?
- Are assistive technology support claims verified with official compatibility docs?

**Framework Accessibility Claims** (Required Quality: B+, 85%+):
- Are React/Vue/Angular accessibility features verified with official framework docs?
- Are component library accessibility claims (Material-UI, Chakra) backed by official docs?
- Are framework-specific accessibility patterns sourced from official guides?
- Are accessibility testing library claims verified with official documentation?

**Research Verification**:
- Has `/gbm.fact-check` been run on accessibility documentation?
- Are WCAG compliance claims verified at 100% quality (Quality A, w3.org or .gov only)?
- Are framework/tool claims verified at 85%+ quality (Quality B+)?
- Are weak sources (Quality C-D) for WCAG claims corrected?

**Note**: For frontend development, WCAG accessibility claims require 100% verification with official W3C sources only (.w3.org or .gov). This is non-negotiable for accessibility-critical features. Use `/gbm.fact-check` to verify and improve claim quality.

---

**Quality Gate Checklist**: Before marking specification as "ready for development":

- [ ] Component architecture and organization strategy are clearly documented
- [ ] State management solution and patterns are specified
- [ ] UI/UX design specifications include visual design, responsive design, and accessibility
- [ ] User interaction patterns cover event handling, forms, feedback, and animations
- [ ] Routing, navigation, and code splitting strategy are defined
- [ ] API integration includes communication, data fetching, error handling, and authentication
- [ ] Performance optimization requirements cover rendering, bundle, assets, and Web Vitals
- [ ] Browser compatibility and feature detection strategy are documented
- [ ] Testing strategy covers unit, integration, E2E, and visual regression testing
- [ ] Build configuration and deployment strategy are specified
- [ ] Developer experience requirements include code quality, tools, and documentation
- [ ] Security measures address input sanitization, CSP, and dependency security
- [ ] Accessibility research quality is verified (critical: WCAG claims at 100%)
