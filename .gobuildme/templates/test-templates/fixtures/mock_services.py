"""
Mock external services fixtures

Provides reusable mocks for external service integration tests:
- Payment services (Stripe, PayPal)
- Email services (SendGrid, Mailgun)
- SMS services (Twilio)
- Cloud storage (S3, GCS)
"""

import pytest
from unittest.mock import Mock, patch, MagicMock

# ============================================================================
# PAYMENT SERVICE MOCKS
# ============================================================================

@pytest.fixture
def mock_stripe():
    """
    SAMPLE FIXTURE: Mock Stripe payment service

    Usage:
        def test_payment(mock_stripe):
            mock_stripe.Charge.create.return_value = {"id": "ch_123", "status": "succeeded"}
            # Test payment processing
    """
    with patch('stripe.Charge') as mock_charge:
        mock_charge.create.return_value = {
            "id": "ch_test_123",
            "status": "succeeded",
            "amount": 1000,
            "currency": "usd"
        }
        yield mock_charge


@pytest.fixture
def mock_stripe_error():
    """
    SAMPLE FIXTURE: Mock Stripe error

    Usage:
        def test_payment_failure(mock_stripe_error):
            # Test error handling
    """
    import stripe
    with patch('stripe.Charge') as mock_charge:
        mock_charge.create.side_effect = stripe.error.CardError(
            message="Your card was declined",
            param="card",
            code="card_declined"
        )
        yield mock_charge


# ============================================================================
# EMAIL SERVICE MOCKS
# ============================================================================

@pytest.fixture
def mock_sendgrid():
    """
    SAMPLE FIXTURE: Mock SendGrid email service

    Usage:
        def test_send_email(mock_sendgrid):
            mock_sendgrid.send.return_value = {"status_code": 202}
            # Test email sending
    """
    with patch('sendgrid.SendGridAPIClient') as mock_sg:
        mock_client = MagicMock()
        mock_client.send.return_value = Mock(status_code=202)
        mock_sg.return_value = mock_client
        yield mock_client


@pytest.fixture
def mock_email_sent():
    """
    SAMPLE FIXTURE: Track sent emails

    Usage:
        def test_email_notification(mock_email_sent):
            # Perform action that sends email
            assert len(mock_email_sent) == 1
            assert mock_email_sent[0]["to"] == "user@example.com"
    """
    sent_emails = []

    def track_email(**kwargs):
        sent_emails.append(kwargs)
        return Mock(status_code=202)

    with patch('app.email.send_email', side_effect=track_email):
        yield sent_emails


# ============================================================================
# SMS SERVICE MOCKS
# ============================================================================

@pytest.fixture
def mock_twilio():
    """
    SAMPLE FIXTURE: Mock Twilio SMS service

    Usage:
        def test_send_sms(mock_twilio):
            mock_twilio.messages.create.return_value = {"sid": "SM123", "status": "sent"}
            # Test SMS sending
    """
    with patch('twilio.rest.Client') as mock_client:
        mock_instance = MagicMock()
        mock_instance.messages.create.return_value = Mock(
            sid="SM_test_123",
            status="sent"
        )
        mock_client.return_value = mock_instance
        yield mock_instance


# ============================================================================
# CLOUD STORAGE MOCKS
# ============================================================================

@pytest.fixture
def mock_s3():
    """
    SAMPLE FIXTURE: Mock AWS S3 storage

    Usage:
        def test_file_upload(mock_s3):
            mock_s3.upload_file.return_value = True
            # Test file upload
    """
    with patch('boto3.client') as mock_boto:
        mock_s3_client = MagicMock()
        mock_s3_client.upload_file.return_value = None
        mock_s3_client.download_file.return_value = None
        mock_s3_client.delete_object.return_value = {"DeleteMarker": True}
        mock_boto.return_value = mock_s3_client
        yield mock_s3_client


@pytest.fixture
def mock_gcs():
    """
    SAMPLE FIXTURE: Mock Google Cloud Storage

    Usage:
        def test_file_upload_gcs(mock_gcs):
            # Test GCS file upload
    """
    with patch('google.cloud.storage.Client') as mock_gcs_client:
        mock_bucket = MagicMock()
        mock_blob = MagicMock()
        mock_bucket.blob.return_value = mock_blob
        mock_gcs_client.return_value.bucket.return_value = mock_bucket
        yield mock_gcs_client


# ============================================================================
# CACHE SERVICE MOCKS
# ============================================================================

@pytest.fixture
def mock_redis():
    """
    SAMPLE FIXTURE: Mock Redis cache

    Usage:
        def test_cache_operations(mock_redis):
            mock_redis.get.return_value = "cached_value"
            # Test cache operations
    """
    with patch('redis.Redis') as mock_redis_client:
        mock_instance = MagicMock()
        mock_instance.get.return_value = None
        mock_instance.set.return_value = True
        mock_instance.delete.return_value = 1
        mock_instance.exists.return_value = False
        mock_redis_client.return_value = mock_instance
        yield mock_instance


# ============================================================================
# MESSAGE QUEUE MOCKS
# ============================================================================

@pytest.fixture
def mock_rabbitmq():
    """
    SAMPLE FIXTURE: Mock RabbitMQ message queue

    Usage:
        def test_publish_message(mock_rabbitmq):
            # Test message publishing
    """
    with patch('pika.BlockingConnection') as mock_connection:
        mock_channel = MagicMock()
        mock_connection.return_value.channel.return_value = mock_channel
        yield mock_channel


@pytest.fixture
def mock_kafka():
    """
    SAMPLE FIXTURE: Mock Kafka message queue

    Usage:
        def test_kafka_producer(mock_kafka):
            # Test Kafka message production
    """
    with patch('kafka.KafkaProducer') as mock_producer:
        mock_instance = MagicMock()
        mock_instance.send.return_value = MagicMock()
        mock_producer.return_value = mock_instance
        yield mock_instance


# ============================================================================
# SEARCH SERVICE MOCKS
# ============================================================================

@pytest.fixture
def mock_elasticsearch():
    """
    SAMPLE FIXTURE: Mock Elasticsearch

    Usage:
        def test_search(mock_elasticsearch):
            mock_elasticsearch.search.return_value = {"hits": {"hits": []}}
            # Test search functionality
    """
    with patch('elasticsearch.Elasticsearch') as mock_es:
        mock_instance = MagicMock()
        mock_instance.search.return_value = {
            "hits": {
                "total": {"value": 0},
                "hits": []
            }
        }
        mock_instance.index.return_value = {"result": "created"}
        mock_es.return_value = mock_instance
        yield mock_instance


# ============================================================================
# HTTP CLIENT MOCKS
# ============================================================================

@pytest.fixture
def mock_http_client():
    """
    SAMPLE FIXTURE: Mock HTTP client (requests/httpx)

    Usage:
        def test_external_api_call(mock_http_client):
            mock_http_client.get.return_value.json.return_value = {"status": "ok"}
            # Test external API call
    """
    with patch('httpx.Client') as mock_client:
        mock_instance = MagicMock()
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"status": "success"}
        mock_instance.get.return_value = mock_response
        mock_instance.post.return_value = mock_response
        mock_client.return_value = mock_instance
        yield mock_instance


# TODO: Add more mocks
# - mock_paypal
# - mock_mailgun
# - mock_vonage (SMS)
# - mock_azure_blob
# - mock_algolia (search)
# - etc.


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def create_mock_response(status_code=200, json_data=None, text=None):
    """
    Helper function to create mock HTTP response

    Usage:
        response = create_mock_response(status_code=200, json_data={"key": "value"})
    """
    mock_response = Mock()
    mock_response.status_code = status_code
    mock_response.json.return_value = json_data or {}
    mock_response.text = text or ""
    return mock_response

