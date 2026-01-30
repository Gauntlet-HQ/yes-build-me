"""
Database test fixtures

Provides reusable fixtures for database integration tests:
- Database session
- Test data cleanup
- Sample models
"""

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base
from app.models import User, Product, Order

# Test database URL (use in-memory SQLite for speed)
TEST_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture(scope="function")
def db_session():
    """
    SAMPLE FIXTURE: Database session with automatic rollback

    Creates a fresh database for each test and rolls back after test completes.

    Usage:
        def test_create_user(db_session):
            user = User(name="Test")
            db_session.add(user)
            db_session.commit()
    """
    # Create engine and tables
    engine = create_engine(TEST_DATABASE_URL)
    Base.metadata.create_all(engine)

    # Create session
    Session = sessionmaker(bind=engine)  # noqa: N806 (SQLAlchemy convention)
    session = Session()

    yield session

    # Cleanup: Rollback and close
    session.rollback()
    session.close()
    Base.metadata.drop_all(engine)


@pytest.fixture
def clean_database(db_session):
    """
    SAMPLE FIXTURE: Clean database before test

    Usage:
        def test_with_clean_db(db_session, clean_database):
            # Database is empty
    """
    # Delete all records from all tables
    for table in reversed(Base.metadata.sorted_tables):
        db_session.execute(table.delete())
    db_session.commit()


@pytest.fixture
def test_user(db_session):
    """
    SAMPLE FIXTURE: Create test user

    Usage:
        def test_user_profile(test_client, test_user):
            response = test_client.get(f"/api/users/{test_user.id}")
    """
    user = User(
        name="Test User",
        email="test@example.com",
        password_hash="hashed_password",  # TODO: Use proper password hashing
        role="user",
        status="active"
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)

    return user


@pytest.fixture
def test_admin_user(db_session):
    """
    SAMPLE FIXTURE: Create test admin user

    Usage:
        def test_admin_endpoint(test_client, test_admin_user):
            # Use admin user for authentication
    """
    admin = User(
        name="Test Admin",
        email="admin@example.com",
        password_hash="hashed_password",  # TODO: Use proper password hashing
        role="admin",
        status="active"
    )
    db_session.add(admin)
    db_session.commit()
    db_session.refresh(admin)

    return admin


@pytest.fixture
def test_product(db_session):
    """
    SAMPLE FIXTURE: Create test product

    Usage:
        def test_product_details(test_client, test_product):
            response = test_client.get(f"/api/products/{test_product.id}")
    """
    product = Product(
        name="Test Product",
        description="Test product description",
        price=99.99,
        stock=100,
        status="active"
    )
    db_session.add(product)
    db_session.commit()
    db_session.refresh(product)

    return product


@pytest.fixture
def test_order(db_session, test_user, test_product):
    """
    SAMPLE FIXTURE: Create test order

    Usage:
        def test_order_details(test_client, test_order):
            response = test_client.get(f"/api/orders/{test_order.id}")
    """
    order = Order(
        user_id=test_user.id,
        product_id=test_product.id,
        quantity=2,
        total_price=199.98,
        status="pending"
    )
    db_session.add(order)
    db_session.commit()
    db_session.refresh(order)

    return order


# TODO: Add more fixtures
# - test_inactive_user
# - test_out_of_stock_product
# - test_completed_order
# - multiple_test_users
# - etc.


@pytest.fixture
def multiple_test_users(db_session):
    """
    SAMPLE FIXTURE: Create multiple test users

    Usage:
        def test_list_users(test_client, multiple_test_users):
            response = test_client.get("/api/users")
            assert len(response.json()["items"]) == 5
    """
    users = []
    for i in range(5):
        user = User(
            name=f"Test User {i}",
            email=f"test{i}@example.com",
            password_hash="hashed_password",
            role="user",
            status="active"
        )
        db_session.add(user)
        users.append(user)

    db_session.commit()
    for user in users:
        db_session.refresh(user)

    return users


@pytest.fixture
def multiple_test_products(db_session):
    """
    SAMPLE FIXTURE: Create multiple test products

    Usage:
        def test_list_products(test_client, multiple_test_products):
            response = test_client.get("/api/products")
            assert len(response.json()["items"]) == 10
    """
    products = []
    for i in range(10):
        product = Product(
            name=f"Test Product {i}",
            description=f"Description for product {i}",
            price=10.00 * (i + 1),
            stock=100 - (i * 10),
            status="active"
        )
        db_session.add(product)
        products.append(product)

    db_session.commit()
    for product in products:
        db_session.refresh(product)

    return products


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def create_user(db_session, **kwargs):
    """
    Helper function to create a user with custom attributes

    Usage:
        user = create_user(db_session, name="Custom User", role="admin")
    """
    defaults = {
        "name": "Test User",
        "email": "test@example.com",
        "password_hash": "hashed_password",
        "role": "user",
        "status": "active"
    }
    defaults.update(kwargs)

    user = User(**defaults)
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)

    return user


def create_product(db_session, **kwargs):
    """
    Helper function to create a product with custom attributes

    Usage:
        product = create_product(db_session, name="Custom Product", price=49.99)
    """
    defaults = {
        "name": "Test Product",
        "description": "Test description",
        "price": 99.99,
        "stock": 100,
        "status": "active"
    }
    defaults.update(kwargs)

    product = Product(**defaults)
    db_session.add(product)
    db_session.commit()
    db_session.refresh(product)

    return product

