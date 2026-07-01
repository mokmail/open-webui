---
name: RAG Knowledge Guide
description: Best practices for working with Open WebUI Knowledge bases — chunking, queries, and retrieval optimization
tags: [rag, knowledge-base, retrieval, embeddings]
version: 1.0.0
---

# RAG Knowledge Guide

## Understanding RAG in Open WebUI

Knowledge bases use Retrieval-Augmented Generation (RAG): documents are chunked, embedded, and stored in a vector database. When you ask a question, the system retrieves relevant chunks and provides them to the model as context.

## Creating Effective Knowledge Bases

### Document Preparation
- Start with clean, well-structured source documents.
- Remove extraneous content: headers/footers, page numbers, navigation elements.
- Use PDFs with selectable text (not scanned images) for best results.
- For scanned documents, ensure OCR quality is high before uploading.
- Split large documents into logical files by chapter or section.

### Chunking Strategy
- Default chunk sizes work for general content. Adjust only if you observe poor retrieval.
- For technical documentation: smaller chunks (300-500 tokens) help target specific answers.
- For narrative content: larger chunks (1000-2000 tokens) preserve context.
- Consider overlap between chunks to avoid splitting important passages.

### Metadata
- Add descriptive filenames that reflect the content.
- Organize related documents into separate knowledge collections.
- Use consistent naming conventions across collections.

## Querying Knowledge Bases

### Writing Effective Queries
- Be specific: "What is the error code for a failed payment?" not "Tell me about errors."
- Use terminology that appears in the source documents.
- Include relevant context: "In the context of user authentication, what happens after token expiry?"
- For multi-part questions, break them into separate queries and synthesize the results.

### When Results Are Poor
- **No results found:** Your query uses different terminology than the source documents. Try synonyms or rephrase.
- **Irrelevant results:** The source documents may not actually cover the topic, or the chunking split important context.
- **Incomplete answers:** The retrieved chunks may be too small. Try merging results from multiple queries.
- **Contradictory answers:** The knowledge base may contain conflicting information. Identify and resolve the source conflict.

### Combining Multiple Knowledge Bases
- Query each collection separately when collections cover distinct domains.
- For overlapping topics, query all relevant collections and synthesize.
- Tag or name results by source collection to track provenance.

## Optimization Tips

- **Test queries before relying on a knowledge base.** Ask 5-10 representative questions and evaluate the quality of retrieved chunks.
- **Monitor chunk overlap.** Too much overlap wastes embedding space; too little may miss context.
- **Refresh knowledge bases** when source documents are updated.
- **Use descriptive document titles** — they appear in citations and help the model attribute information correctly.
- **Combine with system prompts** that tell the model how to use the knowledge: "Answer based on the provided context. If the context doesn't contain the answer, say so."
