---
description: "Generate test fixtures and realistic test data for thorough testing."
artifacts:
  - path: "tests/fixtures/"
    description: "Test fixture files and sample data for testing the feature"
scripts:
  sh: scripts/bash/generate-fixtures.sh
  ps: scripts/powershell/generate-fixtures.ps1
---

## Output Style Requirements (MANDATORY)

**Fixture Output**:
- Factory functions: minimal code, no verbose comments
- One factory per entity type
- Realistic but minimal data - avoid over-generating fields
- No inline explanations - use clear naming

**Fixture Report**:
- Generated files as table: file | entities | count
- Usage examples: one-liner per factory
- No prose about fixture philosophy
For complete style guidance, see .gobuildme/templates/_concise-style.md


You are the Generate Fixtures Command. Your job is to create reusable test fixtures, factories, and realistic test data for thorough testing.

**Context**: This command helps QA Engineers create high-quality test data that can be reused across tests, making tests more maintainable and realistic.

## Workflow

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.qa.generate-fixtures" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

**IMPORTANT**: Run `{SCRIPT}` from the repository root. The script will:
- Automatically check and generate architecture documentation if needed
- Analyze data models and API contracts
- Generate complete test fixtures and factories
- Create mock services for external dependencies
- Generate realistic test data sets
- Generate a detailed fixtures report

The script handles the entire fixture generation process. Do NOT attempt to manually implement the fixture generation logic yourself.

### What the Script Does

The script (`{SCRIPT}`) performs these steps automatically:

Persona Context (optional):
- If `.gobuildme/config/personas.yaml` exists and `default_persona` is set to `qa_engineer`, generates complete fixtures covering all test scenarios.
- If `templates/personas/partials/qa_engineer/generate-fixtures.md` exists, includes enhanced guidance.

**1) Architecture Integration**
   - Checks if architecture documentation exists
   - If missing: Automatically runs `/gbm.architecture` to generate it
   - If old (>7 days): Prompts to refresh
   - Loads architecture context for better fixture generation

**2) Analyze Data Models**
   - Read `data-model.md` for entity structures
   - Read `contracts/` for API contracts
   - Identify all entities that need fixtures
   - Identify relationships between entities
   - Identify required vs optional fields

**3) Generate Pytest Fixtures**

   For each entity, create:

   **Basic Fixtures**:
   - Simple fixture with default values
   - Fixture with all fields populated
   - Fixture with minimal required fields

   **Variant Fixtures**:
   - Valid data variants
   - Invalid data variants
   - Edge case variants
   - Boundary value variants

   **Relationship Fixtures**:
   - Fixtures with related entities
   - Fixtures with nested data
   - Fixtures with collections

**4) Generate Factory Classes**

   Use Factory Boy (Python) or similar for:
   - Dynamic data generation
   - Sequence generation
   - Faker integration
   - Trait-based variants
   - SubFactory for relationships

**5) Generate Mock Services**

   Create mocks for:
   - External APIs (Stripe, SendGrid, etc.)
   - Database connections
   - Message queues
   - File systems
   - Third-party services

**6) Generate Test Data Sets**

   Create data sets for:
   - Happy path scenarios
   - Error scenarios
   - Edge cases
   - Performance testing
   - Security testing

## Output Format

### Pytest Fixtures

```python
# tests/fixtures/user_fixtures.py
import pytest
from datetime import datetime, timedelta
from app.models import User

@pytest.fixture
def valid_user_data():
    """Valid user data for testing"""
    return {
        "email": "test@example.com",
        "password": "SecurePass123!",
        "name": "Test User",
        "role": "user",
        "is_active": True
    }

@pytest.fixture
def admin_user_data():
    """Admin user data for testing"""
    return {
        "email": "admin@example.com",
        "password": "AdminPass123!",
        "name": "Admin User",
        "role": "admin",
        "is_active": True
    }

@pytest.fixture
def inactive_user_data():
    """Inactive user data for testing"""
    return {
        "email": "inactive@example.com",
        "password": "InactivePass123!",
        "name": "Inactive User",
        "role": "user",
        "is_active": False
    }

@pytest.fixture
def user(db_session, valid_user_data):
    """Create a user in the database"""
    user = User(**valid_user_data)
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

@pytest.fixture
def admin_user(db_session, admin_user_data):
    """Create an admin user in the database"""
    user = User(**admin_user_data)
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

@pytest.fixture
def multiple_users(db_session):
    """Create multiple users for testing"""
    users = []
    for i in range(5):
        user = User(
            email=f"user{i}@example.com",
            password=f"Pass{i}123!",
            name=f"User {i}",
            role="user",
            is_active=True
        )
        db_session.add(user)
        users.append(user)
    db_session.commit()
    return users
```

### Factory Classes

```python
# tests/factories/user_factory.py
import factory
from factory.faker import Faker
from app.models import User
from app.database import db_session

class UserFactory(factory.alchemy.SQLAlchemyModelFactory):
    """Factory for creating User instances"""
    
    class Meta:
        model = User
        sqlalchemy_session = db_session
        sqlalchemy_session_persistence = "commit"
    
    # Basic fields
    email = Faker('email')
    password = factory.PostGenerationMethodCall('set_password', 'SecurePass123!')
    name = Faker('name')
    role = "user"
    is_active = True
    
    # Timestamps
    created_at = Faker('date_time_this_year')
    updated_at = factory.LazyAttribute(lambda obj: obj.created_at)
    
    # Traits for variants
    class Params:
        admin = factory.Trait(
            role="admin",
            email=factory.Sequence(lambda n: f"admin{n}@example.com")
        )
        
        inactive = factory.Trait(
            is_active=False
        )
        
        with_posts = factory.Trait(
            posts=factory.RelatedFactoryList(
                'tests.factories.PostFactory',
                'author',
                size=3
            )
        )

# Usage:
# user = UserFactory()                    # Regular user
# admin = UserFactory(admin=True)         # Admin user
# inactive = UserFactory(inactive=True)   # Inactive user
# user_with_posts = UserFactory(with_posts=True)  # User with 3 posts
```

### Mock Services

```python
# tests/fixtures/mock_services.py
import pytest
from unittest.mock import Mock, MagicMock, patch

@pytest.fixture
def mock_stripe():
    """Mock Stripe API"""
    with patch('stripe.Customer') as mock_customer, \
         patch('stripe.Charge') as mock_charge:
        
        # Mock customer creation
        mock_customer.create.return_value = Mock(
            id="cus_test123",
            email="test@example.com",
            created=1234567890
        )
        
        # Mock charge creation
        mock_charge.create.return_value = Mock(
            id="ch_test123",
            amount=1000,
            currency="usd",
            status="succeeded"
        )
        
        yield {
            'customer': mock_customer,
            'charge': mock_charge
        }

@pytest.fixture
def mock_sendgrid():
    """Mock SendGrid API"""
    with patch('sendgrid.SendGridAPIClient') as mock_client:
        mock_response = Mock()
        mock_response.status_code = 202
        mock_response.body = '{"message": "success"}'
        
        mock_client.return_value.send.return_value = mock_response
        
        yield mock_client

@pytest.fixture
def mock_s3():
    """Mock AWS S3"""
    with patch('boto3.client') as mock_boto:
        mock_s3_client = MagicMock()
        
        # Mock upload
        mock_s3_client.upload_file.return_value = None
        
        # Mock download
        mock_s3_client.download_file.return_value = None
        
        # Mock list objects
        mock_s3_client.list_objects_v2.return_value = {
            'Contents': [
                {'Key': 'file1.txt', 'Size': 1024},
                {'Key': 'file2.txt', 'Size': 2048}
            ]
        }
        
        mock_boto.return_value = mock_s3_client
        yield mock_s3_client

@pytest.fixture
def mock_redis():
    """Mock Redis"""
    with patch('redis.Redis') as mock_redis_class:
        mock_redis_instance = MagicMock()
        
        # Mock get/set
        cache = {}
        mock_redis_instance.get.side_effect = lambda k: cache.get(k)
        mock_redis_instance.set.side_effect = lambda k, v: cache.update({k: v})
        mock_redis_instance.delete.side_effect = lambda k: cache.pop(k, None)
        
        mock_redis_class.return_value = mock_redis_instance
        yield mock_redis_instance
```

### Test Data Sets

```python
# tests/fixtures/test_data.py
import pytest

@pytest.fixture
def valid_emails():
    """Valid email addresses for testing"""
    return [
        "user@example.com",
        "test.user@example.com",
        "user+tag@example.com",
        "user123@example.co.uk",
        "user_name@example-domain.com"
    ]

@pytest.fixture
def invalid_emails():
    """Invalid email addresses for testing"""
    return [
        "invalid",
        "@example.com",
        "user@",
        "user @example.com",
        "user@example",
        "user..name@example.com"
    ]

@pytest.fixture
def valid_passwords():
    """Valid passwords for testing"""
    return [
        "SecurePass123!",
        "MyP@ssw0rd",
        "C0mpl3x!Pass",
        "Str0ng#Password"
    ]

@pytest.fixture
def invalid_passwords():
    """Invalid passwords for testing"""
    return [
        "short",           # Too short
        "alllowercase",    # No uppercase
        "ALLUPPERCASE",    # No lowercase
        "NoNumbers!",      # No numbers
        "NoSpecial123"     # No special chars
    ]

@pytest.fixture
def edge_case_strings():
    """Edge case strings for testing"""
    return [
        "",                          # Empty
        " ",                         # Whitespace
        "a" * 1000,                  # Very long
        "Hello\nWorld",              # Newline
        "Hello\tWorld",              # Tab
        "Hello\x00World",            # Null byte
        "🎉 Emoji 🚀",              # Unicode
        "<script>alert('xss')</script>",  # XSS
        "'; DROP TABLE users; --"    # SQL injection
    ]

@pytest.fixture
def boundary_values():
    """Boundary values for testing"""
    return {
        'integers': [
            -2147483648,  # INT_MIN
            -1,
            0,
            1,
            2147483647    # INT_MAX
        ],
        'floats': [
            -1.7976931348623157e+308,  # Float min
            -0.0,
            0.0,
            1.7976931348623157e+308    # Float max
        ],
        'dates': [
            "1970-01-01",  # Unix epoch
            "2000-01-01",  # Y2K
            "2038-01-19",  # 32-bit timestamp limit
            "9999-12-31"   # Max date
        ]
    }
```

### API Response Fixtures

```python
# tests/fixtures/api_fixtures.py
import pytest

@pytest.fixture
def successful_api_response():
    """Successful API response"""
    return {
        "status": "success",
        "data": {
            "id": 123,
            "name": "Test Item",
            "created_at": "2024-01-01T00:00:00Z"
        },
        "message": "Operation successful"
    }

@pytest.fixture
def error_api_response():
    """Error API response"""
    return {
        "status": "error",
        "error": {
            "code": "VALIDATION_ERROR",
            "message": "Invalid input data",
            "details": {
                "email": ["Invalid email format"],
                "password": ["Password too weak"]
            }
        }
    }

@pytest.fixture
def paginated_api_response():
    """Paginated API response"""
    return {
        "status": "success",
        "data": [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"},
            {"id": 3, "name": "Item 3"}
        ],
        "pagination": {
            "page": 1,
            "per_page": 10,
            "total": 100,
            "total_pages": 10
        }
    }
```

## Best Practices

### Fixture Design

1. **Keep fixtures simple**: One fixture, one purpose
2. **Use composition**: Combine simple fixtures for complex scenarios
3. **Avoid side effects**: Fixtures should be predictable
4. **Clean up**: Always clean up resources
5. **Document**: Add docstrings explaining fixture purpose

### Factory Design

1. **Use Faker**: Generate realistic data
2. **Use sequences**: Ensure unique values
3. **Use traits**: Create variants easily
4. **Use SubFactory**: Handle relationships
5. **Keep it DRY**: Reuse factory definitions

### Mock Design

1. **Mock at boundaries**: Mock external services, not internal code
2. **Verify calls**: Use `assert_called_with()` when needed
3. **Return realistic data**: Mocks should return realistic responses
4. **Handle errors**: Mock both success and error cases
5. **Keep it simple**: Don't over-mock

## Next Steps

After generating fixtures, continue with the SDD workflow:

1. **Review Generated Fixtures**
   - Check fixture structure and data
   - Verify mock services work correctly
   - Test factory classes
   - **Why**: Ensure fixtures are correct before using

2. **Implement Tests** (`/gbm.qa.implement` or `/gbm.implement`) - **NEXT COMMAND**
   - Execute tasks from `/gbm.qa.tasks` using TDD approach
   - Convert TODO placeholders into working tests
   - Use generated fixtures in implementations
   - Follow AAA pattern (Arrange, Act, Assert)
   - Mark tasks complete as you finish them
   - **Why**: Systematic TDD implementation with reusable fixtures and progress tracking

3. **Run Tests**: Validate implementation
   ```bash
   pytest tests/ -v                    # Python
   vendor/bin/phpunit                  # PHP
   npm test                            # JavaScript
   mvn test                            # Java
   ```
   **Why**: Ensure tests pass and fixtures work correctly

4. **Review Test Quality** (`/gbm.qa.review-tests`)
   - Validate test quality and coverage
   - Check thresholds (Unit: 90%, Integration: 95%, E2E: 80%)
   - Verify AC traceability
   - **Why**: Catch issues before final review

5. **Final Review** (`/gbm.review`)
   - Complete quality gates validation
   - **Why**: Ready for merge

6. **Maintain**: Update fixtures as models change
   - Keep fixtures in sync with code
   - **Why**: Prevent test failures

## Related Commands

- `/gbm.qa.scaffold-tests` - Generate initial test structure (run first)
- `/gbm.qa.plan` - Create test implementation plan
- `/gbm.qa.tasks` - Generate task breakdown
- `/gbm.qa.implement` - Implement tests using TDD (run next)
- `/gbm.qa.review-tests` - Review test quality
- `/gbm.tests` - Run feature-scoped tests
- `/gbm.review` - Final quality gates

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-qa-generate-fixtures` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit fixture files to improve test data quality
- Re-run `/gbm.qa.plan` if fixture strategy needs revision
- Run `/gbm.clarify` to resolve data model ambiguities
- Re-run `/gbm.qa.generate-fixtures` with updated data model

