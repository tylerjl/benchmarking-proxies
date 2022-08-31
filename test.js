import http from 'k6/http';
import { check, sleep } from 'k6';

http.setResponseCallback(http.expectedStatuses({ min: 200, max: 200 }));

export const options = {
    discardResponseBodies: true,
};

export default function () {
    http.get(`${__ENV.TEST_TARGET}`);
}

export function handleSummary(data) {
    return {
        './summary.json': JSON.stringify(data),
    };
}
