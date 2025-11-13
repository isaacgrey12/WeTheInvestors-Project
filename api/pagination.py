from __future__ import annotations
import base64, json
from typing import Optional, Tuple




def encode_cursor(date_filed: Optional[str], id_: Optional[int]) -> Optional[str]:
    if not date_filed or id_ is None:
        return None
    payload = {"date": date_filed, "id": id_}
    return base64.urlsafe_b64encode(json.dumps(payload).encode()).decode()




def decode_cursor(cur: Optional[str]) -> Tuple[Optional[str], Optional[int]]:
    if not cur:
        return None, None
    try:
        payload = json.loads(base64.urlsafe_b64decode(cur.encode()).decode())
        return payload.get("date"), int(payload.get("id"))
    except Exception:
        return None, None
