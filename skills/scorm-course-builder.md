---
name: SCORM Course Builder
description: Build professional SCORM-compliant eLearning courses from user-provided content or knowledge bases. The course is created as a knowledge base containing all course files, which can be exported/downloaded as a zip. Use when user provides training material, documentation, or asks to create an interactive course package.
tags: [scorm, elearning, training, education, course, content-authoring, knowledge-base]
version: 2.0.0
---

# SCORM Course Builder

## Overview

Transform any content — user-provided text, knowledge base documents, or web-published material — into a professional SCORM 1.2 compliant eLearning course. The course files (HTML modules, manifest, assets) are uploaded to a **knowledge base** in Open WebUI, which the user can then download as a zip file via the KB export endpoint.

## Tools Used

- `search_knowledge_bases(query)` — Find relevant knowledge bases by topic
- `query_knowledge_files(query, knowledge_ids)` — Semantic search within KBs
- `grep_knowledge_files(pattern, knowledge_id)` — Search KB file contents by pattern
- `list_knowledge(knowledge_id)` — List all files in a knowledge base
- `view_knowledge_file(file_id)` — View full content of a KB file
- `fetch_url(url)` — Fetch content from a URL
- `search_web(query)` — Search the web for additional material
- `execute_code(code)` — Run Python to create the KB, upload files, and generate the SCORM package

## Workflow

### 1. Gather Content

Determine the source of course content:

**If user provides content directly:**
- Accept the text, document, or description they provide
- Ask clarifying questions about scope, audience, and depth

**If user references a knowledge base:**
```
search_knowledge_bases(query="{topic}")
```
Then explore matching KBs:
```
list_knowledge(knowledge_id="{id}")
view_knowledge_file(file_id="{id}")
```

**If user provides a URL:**
```
fetch_url(url="{url}")
```

### 2. Analyze & Structure

Organize the content into a pedagogical structure:

| Element | Description |
|---------|-------------|
| **Course Title** | Clear, descriptive name |
| **Overview** | What the learner will achieve |
| **Modules** | Major topic divisions (3-8 recommended) |
| **Lessons** | Sub-topics within each module |
| **Objectives** | What the learner will know after each section |
| **Assessments** | Quiz questions to test comprehension |
| **Summary** | Key takeaways from each module |

For each module, identify:
- Learning objectives (2-4 per module)
- Key concepts and explanations
- Examples or case studies
- Practice questions (3-5 per module, multiple-choice or true/false)

### 3. Create Knowledge Base & Upload Course Files

Use `execute_code` to:
1. Create a knowledge base via `POST /api/v1/knowledge/create`
2. Generate the SCORM course files (HTML modules, `imsmanifest.xml`)
3. Upload each file to the KB via `POST /api/v1/files/` with `knowledge_id` in metadata
4. The KB can then be downloaded as a zip via `GET /api/v1/knowledge/{id}/export`

In **pyodide mode** (default), `fetch()` is available with browser auth cookies. In **jupyter mode**, use `urllib.request`.

#### Step-by-step Python logic

```
execute_code(code="""
import json, io, base64
import js  # pyodide: browser APIs available

origin = js.window.location.origin

# 1. Create the knowledge base
kb_resp = await js.fetch(f"{origin}/api/v1/knowledge/create", {{
    "method": "POST",
    "headers": {{"Content-Type": "application/json"}},
    "body": JSON.stringify({{
        "name": "{Course Name}",
        "description": "SCORM eLearning course: {Course Name}",
        "access_grants": []
    }})
}})
kb = await kb_resp.json()
kb_id = kb["id"]
print(f"Created KB: {{kb_id}}")

# 2. Build SCORM content — create imsmanifest.xml and one HTML per module
import xml.etree.ElementTree as ET

# Build imsmanifest.xml
# ... (construct manifest with proper SCORM 1.2 namespaces)

# Build each module HTML with SCORM API + quiz JS
modules = [
    ("module-1.html", "<html>...Module 1 content...</html>"),
    ("module-2.html", "<html>...Module 2 content...</html>"),
]
files = [("imsmanifest.xml", manifest_xml)] + modules

# 3. Upload each file to the knowledge base
for filename, content in files:
    blob = js.Blob.new([content], {{"type": "text/html" if filename.endswith('.html') else "text/xml"}})
    form = js.FormData.new()
    form.append("file", blob, filename)
    # Include knowledge_id in metadata to auto-link to KB
    form.append("metadata", json.dumps({{"knowledge_id": kb_id}}))
    resp = await js.fetch(f"{{origin}}/api/v1/files/", {{
        "method": "POST",
        "body": form
    }})
    result = await resp.json()
    print(f"Uploaded {{filename}}: {{result.get('id', 'error')}}")

# 4. Report the KB export URL
print(f"KB created: {{origin}}/admin/knowledge/{{kb_id}}")
print(f"KB export/download: {{origin}}/api/v1/knowledge/{{kb_id}}/export")
""")
```

**Jupyter mode** (same logic with `urllib.request`):
```python
import json, io, base64, urllib.request, os

base_url = os.environ.get("OPEN_WEBUI_URL", "http://host.docker.internal:3000")

# 1. Create KB
req = urllib.request.Request(
    f"{base_url}/api/v1/knowledge/create",
    data=json.dumps({"name": "{Course Name}", "description": "...", "access_grants": []}).encode(),
    headers={"Content-Type": "application/json"},
)
resp = urllib.request.urlopen(req)
kb = json.loads(resp.read())
kb_id = kb["id"]

# 2. Build & upload files (same content generation as above)
# Use multipart POST for each file

# 3. Upload each file with knowledge_id in metadata
import uuid

def upload_file(filename, content, kb_id):
    boundary = f'----{uuid.uuid4().hex}'
    body = []
    body.append(f'--{boundary}')
    body.append(f'Content-Disposition: form-data; name="file"; filename="{filename}"')
    body.append(f'Content-Type: text/html; charset=utf-8')
    body.append('')
    body.append(content if isinstance(content, str) else content.decode())
    body.append(f'--{boundary}')
    body.append(f'Content-Disposition: form-data; name="metadata"')
    body.append('')
    body.append(json.dumps({"knowledge_id": kb_id}))
    body.append(f'--{boundary}--')
    body = '\r\n'.join(body).encode()

    req = urllib.request.Request(
        f"{base_url}/api/v1/files/",
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
    )
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())

print(f"KB created: {base_url}/api/v1/knowledge/{kb_id}/export")
```

#### Building imsmanifest.xml

Generate the manifest with proper SCORM 1.2 namespaces. Each module HTML is a SCO resource:

```python
import xml.etree.ElementTree as ET

def build_manifest(modules, course_id="course1"):
    manifest = ET.Element("manifest", {
        "identifier": course_id, "version": "1.1",
        "xmlns": "http://www.imsproject.org/xsd/imscp_rootv1p1p2",
        "xmlns:adlcp": "http://www.adlnet.org/xsd/adlcp_rootv1p2",
    })
    metadata = ET.SubElement(manifest, "metadata")
    ET.SubElement(metadata, "schema").text = "ADL SCORM"
    ET.SubElement(metadata, "schemaversion").text = "1.2"

    orgs = ET.SubElement(manifest, "organizations", default="org1")
    org = ET.SubElement(orgs, "organization", identifier="org1")
    ET.SubElement(org, "title").text = "{Course Title}"

    res = ET.SubElement(manifest, "resources")
    for i, (filename, _) in enumerate(modules):
        item = ET.SubElement(org, "item", identifier=f"item-{i+1}", identifierref=f"res-{i+1}")
        ET.SubElement(item, "title").text = f"Module {{i+1}}"
        r = ET.SubElement(res, "resource", identifier=f"res-{i+1}", type="webcontent",
                          adlcp:scormtype="sco", href=filename)
        ET.SubElement(r, "file", href=filename)

    return ET.tostring(manifest, encoding="unicode", xml_declaration=True)
```

#### Module HTML template

Each module HTML file must include SCORM API integration for LMS tracking:

```html
<!DOCTYPE html>
<html><head><title>Module Title</title>
<style>
  body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
  .content {{ max-width: 800px; margin: 0 auto; }}
  .quiz {{ background: #f7fafc; padding: 20px; border-radius: 8px; }}
  .nav {{ margin-top: 30px; text-align: center; }}
  .btn {{ padding: 10px 20px; background: #2b6cb0; color: #fff;
          border: none; border-radius: 5px; cursor: pointer; }}
</style>
<script>
var API = window.API || parent.API;
var status = "incomplete"; var score = 0;
function init() {{ API && API.LMSInitialize && API.LMSInitialize(""); }}
function finish() {{
  API && (API.LMSSetValue("cmi.core.lesson_status", status),
          API.LMSSetValue("cmi.core.score.raw", score),
          API.LMSSetValue("cmi.core.score.max", 100),
          API.LMSFinish(""));
}}
function grade() {{ /* grade quiz, set status/score */ }}
window.onload = init; window.onunload = finish;
</script></head><body>
<div class="content">
  <h1>Module Title</h1>
  <h2>Learning Objectives</h2>
  <ul><li>Objective 1</li><li>Objective 2</li></ul>
  <h2>Content</h2>
  <p>Lesson content...</p>
  <div class="quiz"><h3>Knowledge Check</h3><!-- quiz questions --></div>
  <div class="nav"><button class="btn" onclick="grade()">Submit</button></div>
</div></body></html>
```

### 4. Output & Delivery

Present the result to the user:

- **Course outline** — Display the module structure for review
- **Knowledge base URL** — Provide the KB link: `{origin}/admin/knowledge/{kb_id}` (or workspace view)
- **Download/export URL** — Provide the KB export link: `{origin}/api/v1/knowledge/{kb_id}/export` — returns a downloadable zip containing all course files
- **For LMS deployment** — The export zip contains the raw HTML/XML files. Rename `.txt` → `.html`/`.xml` and repackage into a proper SCORM zip (with `imsmanifest.xml` at root), or use `execute_code` to generate a ready-to-upload SCORM zip as an additional file in the KB
- **Deployment instructions** — Explain how to upload to any LMS (Moodle, Canvas, Blackboard, etc.)

**Why knowledge base?** KBs persist in the database, survive container restarts, are accessible from any device, support semantic search, and can be **downloaded as a zip** at any time via the export endpoint.

## Important Notes

- SCORM 1.2 is the most widely supported LMS standard
- Each module HTML file is a SCO (Sharable Content Object) with its own SCORM API calls
- Quiz scores are reported via `cmi.core.score.raw` and `cmi.core.score.max`
- Lesson status values: `"passed"`, `"completed"`, `"failed"`, `"incomplete"`, `"browsed"`, `"not attempted"`
- Test with `execute_code` to ensure files upload correctly
- For large courses, split content into multiple modules and upload sequentially
- If API calls fail in `execute_code`, check network access and retry — browser cookies (pyodide) or `host.docker.internal` (jupyter) may need configuration
