# Excel Reader MCP Server

한국투자증권 API 명세 등 `.xlsx` 파일을 Cursor에서 읽고 검증하기 위한 **Python 기반 MCP 서버**입니다.  
pandas + openpyxl로 동작하며, 무료·범용으로 CSV/엑셀 데이터를 다룰 수 있습니다.

## 요구사항

- Python 3.10+
- pandas, openpyxl

## 설치

```bash
cd mcp-servers/excel-reader
pip install -r requirements.txt
```

(또는 프로젝트 루트에서: `pip install -r mcp-servers/excel-reader/requirements.txt`)

## Cursor 연동

1. **설정 복사**  
   `.cursor/mcp.json.template` 내용 중 `excel-reader` 항목을 실제 사용하는 MCP 설정 파일(예: `.cursor/mcp.json`)에 넣습니다.

2. **반드시 `command`에 Python 실행 파일 전체 경로 사용**  
   - Cursor에서 `"command": "python"` 사용 시 Windows가 스토어용 스텁을 실행해 프로세스가 바로 종료될 수 있음.  
   - `.cursor/mcp.json`에 복사할 때 **`mcp.json.template`에 있는 전체 경로**(예: `C:/Users/.../pythoncore-3.14-64/python.exe`)를 그대로 쓰거나, 본인 PC에서 `py -c "import sys; print(sys.executable)"` 로 확인한 경로를 사용하세요.
3. **경로·실행 확인**  
   - `args`의 `server.py` 경로와 `env.MCP_EXCEL_PROJECT_ROOT`가 현재 프로젝트 루트(워크스페이스 루트)를 가리키도록 수정합니다.  
   - 다른 PC에서는 해당 경로를 각자 환경에 맞게 바꿔야 합니다.

3. **Cursor 재시작**  
   MCP 설정을 바꾼 뒤 Cursor를 다시 띄우면 Excel Reader MCP가 로드됩니다.

## 제공 도구 (Tools)

| 도구 | 설명 |
|------|------|
| `sheet_names` | 엑셀 파일의 시트 이름 목록을 JSON 배열로 반환 |
| `read_excel` | 지정 시트를 마크다운 테이블 또는 JSON으로 읽기 (선택: `max_rows`, `as_markdown`) |
| `export_csv` | 지정 시트를 CSV로 내보내기 |
| `validate_schema` | 시트의 컬럼명·dtype 요약(스키마) 반환 |

모든 `file_path`는 **프로젝트 루트 기준 상대 경로** 또는 **프로젝트 루트 하위의 절대 경로**만 허용됩니다.

### 예시 (상대 경로)

- `investment-backend/docs/korea-investment-api/OAuth인증.xlsx`
- `investment-backend/docs/korea-investment-api/[국내주식] 기본시세.xlsx`

## 사용 목적

- **API 명세서 정리**: `docs/korea-investment-api/` 내 xlsx 시트 목록·컬럼 구조 확인
- **전체 API 명세서 문서화**: `read_excel`로 시트 내용을 읽어 마크다운/문서에 반영
- **QA·검증**: 스키마 확인·CSV 추출로 테스트 데이터 또는 스펙 검증 자동화

## 로컬에서 서버만 실행 (디버깅)

```bash
cd mcp-servers/excel-reader
set MCP_EXCEL_PROJECT_ROOT=D:\works\pjt\auto-investment-project
python server.py
```

stdio로 대기하므로, MCP 클라이언트로 접속해 도구를 호출할 수 있습니다.
