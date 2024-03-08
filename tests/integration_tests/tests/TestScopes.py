from tests.utils import *


class TestScopes(unittest.TestCase):

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True,
        'scope': ['poop']
    })
    @authenticate(create_consumer=True)
    @call_api()
    def test_bad_scope(self, status, body):
        self.assertEqual(FORBIDDEN, status)

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True,
        'scope': ['email']
    })
    @authenticate(create_consumer=True)
    @call_api()
    def test_good_scope(self, status, body):
        self.assertEqual(OK, status)
        self.assertIn('x-consumer-scopes', body.get('headers'))
        self.assertIn('email', body.get('headers').get('x-consumer-scopes'))

    @create_api({
        'allowed_iss': ['http://localhost:8080/auth/realms/master'],
        'consumer_match': True
    })
    @authenticate(create_consumer=True)
    @call_api()
    def test_scope_header(self, status, body):
        self.assertEqual(OK, status)
        self.assertIn('x-consumer-scopes', body.get('headers'))
        self.assertIn('email', body.get('headers').get('x-consumer-scopes'))