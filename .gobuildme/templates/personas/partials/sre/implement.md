### Persona-Specific Implementation Guidance — Site Reliability Engineer (SRE)

Implementation best practices for site reliability engineering:

**Service Reliability Design**:
- Define and implement Service Level Objectives (SLOs)
- Calculate error budgets based on SLOs
- Design systems with appropriate fault tolerance
- Implement proper circuit breakers and bulkheads
- Design for graceful degradation
- Implement proper timeout and retry strategies
- Use chaos engineering to validate resilience
- Design systems to be stateless when possible

**Monitoring & Observability**:
- Implement comprehensive metrics collection (Prometheus, Datadog, New Relic)
- Set up distributed tracing (Jaeger, Zipkin, OpenTelemetry)
- Implement structured logging with proper log levels
- Create observability dashboards for key metrics
- Monitor the four golden signals (latency, traffic, errors, saturation)
- Implement synthetic monitoring for critical paths
- Set up real user monitoring (RUM)
- Use log aggregation tools (ELK, Splunk, Loki)

**Alerting & Incident Response**:
- Implement actionable alerts based on SLOs
- Avoid alert fatigue with proper thresholds
- Create tiered alerting (warning, critical)
- Implement on-call rotation and escalation policies
- Develop incident response procedures
- Create runbooks for common incidents
- Implement post-incident review (blameless postmortems)
- Track MTTD (Mean Time to Detect) and MTTR (Mean Time to Resolve)

**Infrastructure as Code**:
- Define all infrastructure with IaC (Terraform, CloudFormation, Pulumi)
- Version control infrastructure definitions
- Implement proper module structure for reusability
- Use workspaces for environment management
- Implement proper state management and locking
- Test infrastructure changes in non-production first
- Implement CI/CD for infrastructure deployments
- Document infrastructure architecture and dependencies

**Deployment Strategies**:
- Implement zero-downtime deployments
- Use rolling deployments for gradual rollout
- Implement canary deployments for risk mitigation
- Use blue-green deployments for quick rollback
- Implement feature flags for gradual feature rollout
- Automate deployment pipelines with proper gates
- Monitor deployments with automatic rollback triggers
- Document deployment procedures and rollback steps

**Capacity Planning & Scaling**:
- Monitor resource utilization trends (CPU, memory, network, disk)
- Implement predictive capacity planning
- Design systems for horizontal scalability
- Implement auto-scaling based on metrics
- Use load testing to validate capacity
- Plan for traffic spikes and seasonal variations
- Right-size resources to optimize costs
- Document scaling procedures and thresholds

**Disaster Recovery & Business Continuity**:
- Implement proper backup strategies (automated, tested)
- Design multi-region/multi-zone architectures
- Implement database replication and failover
- Create and test disaster recovery plans
- Document Recovery Time Objective (RTO) and Recovery Point Objective (RPO)
- Implement proper data retention policies
- Test backups regularly with restore procedures
- Create runbooks for disaster recovery scenarios

**Performance Engineering**:
- Profile applications to identify bottlenecks
- Implement proper caching strategies (CDN, application cache, database cache)
- Optimize database queries and indexing
- Implement connection pooling and reuse
- Use load balancing for distributing traffic
- Optimize network latency with proper architecture
- Implement rate limiting to prevent abuse
- Monitor and optimize web vitals and page load times

**Security & Compliance**:
- Implement defense in depth security strategy
- Use proper secrets management (Vault, AWS Secrets Manager)
- Implement network security (firewalls, security groups)
- Use principle of least privilege for access control
- Implement security monitoring and threat detection
- Conduct regular security audits and penetration testing
- Ensure compliance with relevant standards (SOC 2, ISO 27001)
- Implement proper encryption (at rest and in transit)

**Container Orchestration**:
- Implement Kubernetes for container orchestration
- Design proper pod resource requests and limits
- Implement health checks (liveness, readiness, startup)
- Use proper ConfigMaps and Secrets management
- Implement horizontal pod autoscaling
- Design proper network policies
- Use service meshes for advanced traffic management (Istio, Linkerd)
- Monitor container resource utilization

**CI/CD Pipeline Management**:
- Implement robust CI/CD pipelines
- Use proper artifact management and versioning
- Implement automated testing gates (unit, integration, E2E)
- Use security scanning in pipelines (SAST, DAST, dependency scanning)
- Implement deployment gates and approvals
- Monitor pipeline performance and success rates
- Implement proper secret handling in pipelines
- Document pipeline architecture and processes

**Cost Optimization**:
- Monitor cloud spending with detailed cost allocation
- Implement cost alerts and budgets
- Right-size resources based on utilization
- Use spot/preemptible instances for non-critical workloads
- Implement auto-scaling to match demand
- Optimize data transfer and storage costs
- Use reserved instances for predictable workloads
- Track cost per service and feature

**Database Reliability**:
- Implement proper database backups and point-in-time recovery
- Design for database high availability and failover
- Implement read replicas for read-heavy workloads
- Monitor database performance metrics
- Implement proper indexing strategies
- Use connection pooling to prevent connection exhaustion
- Implement database migration strategies with minimal downtime
- Test database disaster recovery procedures

**Load Balancing & Traffic Management**:
- Implement proper load balancing strategies
- Use health checks for backend health monitoring
- Implement proper session affinity when needed
- Configure timeouts and connection limits
- Implement rate limiting and DDoS protection
- Use geo-routing for global traffic distribution
- Monitor load balancer metrics and errors
- Implement proper SSL/TLS termination

**Testing Strategy**:
- Implement chaos engineering experiments (Chaos Monkey, Gremlin)
- Conduct load testing and stress testing
- Implement failure injection testing
- Test disaster recovery and backup restoration
- Validate auto-scaling behavior under load
- Test monitoring and alerting systems
- Conduct security testing and vulnerability scanning
- Test deployment and rollback procedures

**Change Management**:
- Implement proper change review processes
- Use change windows for risky changes
- Maintain change logs and audit trails
- Implement gradual rollouts for changes
- Use feature flags to control change impact
- Test changes thoroughly in non-production
- Implement automatic rollback for failed changes
- Communicate changes to stakeholders

**On-Call & Incident Management**:
- Establish clear on-call rotation schedules
- Implement escalation policies and procedures
- Use incident management tools (PagerDuty, Opsgenie)
- Create incident response playbooks
- Conduct post-incident reviews (PIRs)
- Track and analyze incident trends
- Implement incident severity classification
- Document lessons learned and action items

**Automation & Toil Reduction**:
- Identify and eliminate repetitive manual tasks
- Automate operational procedures with scripts
- Use infrastructure automation tools
- Implement self-healing systems
- Automate incident response where possible
- Create chatbots for common operational tasks
- Track time spent on toil vs. engineering work
- Prioritize automation projects based on impact

**Documentation**:
- Maintain comprehensive runbooks for all services
- Document architecture and system dependencies
- Create troubleshooting guides for common issues
- Document SLOs, SLIs, and error budgets
- Maintain disaster recovery procedures
- Document on-call procedures and escalation paths
- Create operational dashboards and reports
- Maintain infrastructure documentation with diagrams
