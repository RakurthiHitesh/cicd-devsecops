#!/bin/bash
# ============================================================
# trivy-scan.sh — Run Trivy container vulnerability scan
# Usage: ./scripts/trivy-scan.sh <image:tag>
# ============================================================

set -e

IMAGE=${1:-"flask-devsecops-app:latest"}
REPORT_DIR="trivy-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "============================================"
echo " Trivy Vulnerability Scanner"
echo " Image : $IMAGE"
echo " Time  : $TIMESTAMP"
echo "============================================"

mkdir -p "$REPORT_DIR"

# Install Trivy if not present
if ! command -v trivy &> /dev/null; then
  echo "[INFO] Trivy not found — installing..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

# Run scan — fail on HIGH/CRITICAL
echo ""
echo "[INFO] Scanning for HIGH and CRITICAL vulnerabilities..."
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  --no-progress \
  --format table \
  "$IMAGE"

# Also save JSON report
echo ""
echo "[INFO] Saving JSON report to $REPORT_DIR/trivy_${TIMESTAMP}.json..."
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 0 \
  --no-progress \
  --format json \
  --output "$REPORT_DIR/trivy_${TIMESTAMP}.json" \
  "$IMAGE"

echo ""
echo "[SUCCESS] Scan complete. Report saved to $REPORT_DIR/trivy_${TIMESTAMP}.json"
