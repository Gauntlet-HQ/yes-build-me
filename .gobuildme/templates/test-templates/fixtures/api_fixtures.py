"""
API test fixtures

Provides reusable fixtures for API integration tests:
- Test client
- Authentication headers
- Sample request data
- Mock responses
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def test_client():
    """
    SAMPLE FIXTURE: FastAPI test client

    Usage:
        def test_endpoint(test_client):
            response = test_client.get("/api/users")
    """
    return TestClient(app)


@pytest.fixture
def auth_headers(test_user):
    """
    SAMPLE FIXTURE: Authentication headers with valid token

    Usage:
        def test_protected_endpoint(test_client, auth_headers):
            response = test_client.get("/api/protected", headers=auth_headers)
    """
    from app.auth import create_access_token

    token = create_access_token(user_id=test_user.id)
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }


@pytest.fixture
def admin_auth_headers(test_admin_user):
    """
    SAMPLE FIXTURE: Admin authentication headers

    Usage:
        def test_admin_endpoint(test_client, admin_auth_headers):
            response = test_client.get("/api/admin/users", headers=admin_auth_headers)
    """
    from app.auth import create_access_token

    token = create_access_token(user_id=test_admin_user.id)
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }


@pytest.fixture
def sample_user_data():
    """
    SAMPLE FIXTURE: Sample user data for testing

    Usage:
        def test_create_user(test_client, sample_user_data):
            response = test_client.post("/api/users", json=sample_user_data)
    """
    return {
        "name": "Test User",
        "email": "test@example.com",
        "password": "SecurePassword123!",
        # TODO: Add more fields as needed
    }


@pytest.fixture
def sample_product_data():
    """
    SAMPLE FIXTURE: Sample product data for testing

    Usage:
        def test_create_product(test_client, sample_product_data):
            response = test_client.post("/api/products", json=sample_product_data)
    """
    return {
        "name": "Test Product",
        "description": "Test product description",
        "price": 99.99,
        "stock": 100,
        # TODO: Add more fields as needed
    }


# TODO: Add more fixtures
# - sample_order_data
# - sample_payment_data
# - invalid_user_data
# - etc.


@pytest.fixture
def mock_api_response():
    """
    SAMPLE FIXTURE: Mock API response

    Usage:
        def test_external_api(mock_api_response):
            # Use mock_api_response in test
    """
    return {
        "status": "success",
        "data": {
            "id": "test_123",
            "created_at": "2025-01-07T12:00:00Z"
        }
    }


@pytest.fixture
def pagination_params():
    """
    SAMPLE FIXTURE: Pagination parameters

    Usage:
        def test_list_with_pagination(test_client, pagination_params):
            response = test_client.get("/api/users", params=pagination_params)
    """
    return {
        "page": 1,
        "page_size": 10
    }


@pytest.fixture
def filter_params():
    """
    SAMPLE FIXTURE: Filter parameters

    Usage:
        def test_list_with_filters(test_client, filter_params):
            response = test_client.get("/api/users", params=filter_params)
    """
    return {
        "status": "active",
        "role": "user"
    }


@pytest.fixture
def sort_params():
    """
    SAMPLE FIXTURE: Sort parameters

    Usage:
        def test_list_with_sorting(test_client, sort_params):
            response = test_client.get("/api/users", params=sort_params)
    """
    return {
        "sort_by": "created_at",
        "sort_order": "desc"
    }

