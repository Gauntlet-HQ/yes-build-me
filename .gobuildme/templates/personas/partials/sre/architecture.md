## SRE-Specific Architecture Documentation

As an **SRE (Site Reliability Engineer)**, your focus is on documenting deployment architecture, scalability, reliability, observability, and operational excellence.

### Deployment Architecture

**Required**: Document deployment infrastructure in `.gobuildme/docs/technical/architecture/patterns/deployment.md`

Include:
- **Infrastructure Platform**: AWS, GCP, Azure, on-premises, or hybrid
- **Container Strategy**: Docker, containerd, or other
- **Orchestration**: Kubernetes, ECS, Docker Swarm, or other
- **Infrastructure as Code**: Terraform, CloudFormation, Pulumi
- **Configuration Management**: Ansible, Chef, Puppet, or other
- **Deployment Topology**: Multi-region, multi-AZ, single region
- **Network Architecture**: VPCs, subnets, security groups, load balancers
- **Service Mesh**: Istio, Linkerd, or other if applicable

### Scalability Architecture

**Required**: Document scaling strategies

Include:
- **Horizontal Scaling**: How services scale out
- **Vertical Scaling**: When and how to scale up
- **Auto-Scaling**: Auto-scaling policies and triggers
- **Load Balancing**: Load balancer configuration and algorithms
- **Database Scaling**: Read replicas, sharding, partitioning
- **Caching Strategy**: Redis, Memcached, CDN usage
- **Queue-Based Load Leveling**: Message queues for traffic smoothing
- **Capacity Planning**: How capacity is planned and monitored

### Reliability and Resilience

**Required**: Document reliability patterns

Include:
- **High Availability**: HA configuration and failover
- **Disaster Recovery**: DR strategy, RTO, RPO
- **Backup Strategy**: What is backed up, frequency, retention
- **Circuit Breakers**: Fault tolerance patterns
- **Retry Logic**: Retry strategies with exponential backoff
- **Timeouts**: Timeout configurations across services
- **Health Checks**: Liveness and readiness probes
- **Graceful Degradation**: How system degrades under load
- **Chaos Engineering**: Chaos testing practices if applicable

### Observability Architecture

**Required**: Document monitoring and observability

Include:
- **Metrics**: What metrics are collected (Prometheus, CloudWatch, Datadog)
- **Logging**: Centralized logging (ELK, Splunk, CloudWatch Logs)
- **Tracing**: Distributed tracing (Jaeger, Zipkin, X-Ray)
- **Dashboards**: Key dashboards and what they show
- **Alerting**: Alert rules, thresholds, and escalation
- **SLIs/SLOs/SLAs**: Service level indicators, objectives, agreements
- **Error Budgets**: How error budgets are calculated and used
- **On-Call**: On-call rotation and incident response

### CI/CD Pipeline

**Required**: Document continuous integration and deployment

Include:
- **CI Platform**: GitHub Actions, GitLab CI, Jenkins, CircleCI
- **Build Pipeline**: Build stages and validation
- **Test Automation**: Automated testing in pipeline
- **Security Scanning**: SAST, DAST, dependency scanning
- **Artifact Management**: Where artifacts are stored
- **Deployment Stages**: Dev, staging, production environments
- **Deployment Strategy**: Blue-green, canary, rolling updates
- **Rollback Process**: How to rollback deployments
- **Approval Gates**: Manual approval requirements

### Security and Compliance

**Required**: Document security architecture from SRE perspective

Include:
- **Secrets Management**: Vault, AWS Secrets Manager, or other
- **Certificate Management**: TLS/SSL certificate handling
- **Network Security**: Firewalls, security groups, WAF
- **Access Control**: IAM, RBAC, service accounts
- **Audit Logging**: What is logged for compliance
- **Compliance Requirements**: SOC2, HIPAA, GDPR, or other
- **Vulnerability Management**: How vulnerabilities are tracked
- **Incident Response**: Security incident response process

### Cost Optimization

**Required**: Document cost management strategies

Include:
- **Resource Tagging**: How resources are tagged for cost tracking
- **Cost Monitoring**: How costs are monitored and reported
- **Right-Sizing**: How resources are sized appropriately
- **Reserved Instances**: Use of reserved or committed capacity
- **Spot Instances**: Use of spot/preemptible instances
- **Auto-Scaling**: Cost-aware auto-scaling policies
- **Resource Cleanup**: How unused resources are identified and removed

### Operational Runbooks

**Required**: Document operational procedures

Include:
- **Deployment Runbook**: Step-by-step deployment process
- **Rollback Runbook**: How to rollback a deployment
- **Incident Response**: How to respond to incidents
- **Scaling Runbook**: How to manually scale services
- **Backup and Restore**: How to backup and restore data
- **Common Issues**: Known issues and resolutions
- **Emergency Contacts**: Who to contact for what

### SRE Checklist for `/gbm.architecture`

Before completing the architecture documentation, verify:

- [ ] **Deployment Architecture**: Infrastructure and deployment documented
- [ ] **Scalability**: Scaling strategies and capacity planning documented
- [ ] **Reliability**: HA, DR, and resilience patterns documented
- [ ] **Observability**: Monitoring, logging, and tracing documented
- [ ] **CI/CD**: Pipeline and deployment process documented
- [ ] **Security**: Security architecture and compliance documented
- [ ] **Cost Management**: Cost optimization strategies documented
- [ ] **Runbooks**: Operational procedures documented
- [ ] **SLIs/SLOs**: Service level objectives defined
- [ ] **Incident Response**: Incident response process documented

