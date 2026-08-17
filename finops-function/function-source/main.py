import base64
import json
import logging
import os

import functions_framework
import requests

logging.basicConfig(level=logging.INFO)


@functions_framework.cloud_event
def process_budget_alert(cloud_event):
    """Processes a GCP budget alert Pub/Sub message.

    Triggered by the google.cloud.pubsub.topic.v1.messagePublished event
    configured in main.tf's event_trigger block. Always logs the alert to
    Cloud Logging. If the TEAMS_WEBHOOK_URL environment variable is set
    (wired from Secret Manager via secret_environment), also forwards a
    basic summary card to that Microsoft Teams Incoming Webhook.
    """
    message_data = cloud_event.data.get("message", {}).get("data")
    payload = json.loads(base64.b64decode(message_data)) if message_data else {}

    logging.info("Budget alert received: %s", json.dumps(payload))

    webhook_url = os.environ.get("TEAMS_WEBHOOK_URL")
    if not webhook_url:
        return

    _post_to_teams(webhook_url, payload)


def _post_to_teams(webhook_url, payload):
    budget_display_name = payload.get("budgetDisplayName", "unknown budget")
    cost_amount = payload.get("costAmount")
    cost_interval_start = payload.get("costIntervalStart")
    budget_amount = payload.get("budgetAmount")
    currency_code = payload.get("currencyCode", "")
    threshold = payload.get("alertThresholdExceeded")

    lines = [f"**Budget alert: {budget_display_name}**"]
    if cost_amount is not None and budget_amount is not None:
        lines.append(f"Spend: {cost_amount} {currency_code} / Budget: {budget_amount} {currency_code}")
    if threshold is not None:
        lines.append(f"Threshold exceeded: {threshold:.0%}")
    if cost_interval_start:
        lines.append(f"Interval start: {cost_interval_start}")

    card = {"text": "\n\n".join(lines)}

    response = requests.post(webhook_url, json=card, timeout=10)
    response.raise_for_status()
