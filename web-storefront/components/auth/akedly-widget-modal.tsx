'use client';

import { useEffect } from 'react';

type AkedlyWidgetResult = {
  status: string;
  attemptId?: string;
  transactionId?: string;
};

type AkedlyWidgetModalProps = {
  open: boolean;
  iframeUrl: string;
  onClose: () => void;
  onResult: (result: AkedlyWidgetResult) => void;
};

const AKEDLY_WIDGET_ORIGIN = 'https://auth.akedly.io';

const parseMessage = (value: unknown): AkedlyWidgetResult | null => {
  if (!value) return null;

  const payload = typeof value === 'string'
    ? (() => {
      try {
        return JSON.parse(value) as Record<string, unknown>;
      } catch (_error) {
        return null;
      }
    })()
    : (value as Record<string, unknown>);

  if (!payload) return null;

  const status = String(
    payload.status
    || payload.eventStatus
    || payload.event_status
    || '',
  ).toLowerCase();

  if (!status) return null;

  const attempt = payload.attempt as Record<string, unknown> | undefined;
  const transaction = payload.transaction as Record<string, unknown> | undefined;

  const attemptId = String(
    payload.attemptId
    || payload.attempt_id
    || attempt?.id
    || '',
  ).trim();

  const transactionId = String(
    payload.transactionId
    || payload.transaction_id
    || transaction?.id
    || payload.id
    || '',
  ).trim();

  return {
    status,
    ...(attemptId ? { attemptId } : {}),
    ...(transactionId ? { transactionId } : {}),
  };
};

export function AkedlyWidgetModal({
  open,
  iframeUrl,
  onClose,
  onResult,
}: AkedlyWidgetModalProps) {
  useEffect(() => {
    if (!open) return undefined;

    const handleMessage = (event: MessageEvent) => {
      if (event.origin !== AKEDLY_WIDGET_ORIGIN) {
        return;
      }

      const parsed = parseMessage(event.data);
      if (!parsed) return;

      onResult(parsed);
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, [open, onResult]);

  if (!open) {
    return null;
  }

  return (
    <div className="akedly-modal-overlay" role="dialog" aria-modal="true" aria-label="Phone verification">
      <div className="akedly-modal-card">
        <div className="akedly-modal-header">
          <h2>Verify your phone</h2>
          <button type="button" className="btn secondary" onClick={onClose}>Close</button>
        </div>
        <iframe
          src={iframeUrl}
          title="Akedly OTP Widget"
          className="akedly-widget-iframe"
          allow="clipboard-write"
        />
      </div>
    </div>
  );
}
