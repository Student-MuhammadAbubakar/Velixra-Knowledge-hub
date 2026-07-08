from sentence_transformers import SentenceTransformer

# Loaded ONCE at import time, not per-request — loading this model is expensive
# (reads a few hundred MB from disk), so it should never happen inside a function
# that runs on every chunk or every chat message.
_model = SentenceTransformer("all-MiniLM-L6-v2")


def embed_text(text: str) -> list[float]:
    """
    Converts a piece of text into a 384-dimension embedding vector.
    Used both when embedding document chunks (upload) and questions (chat) —
    both sides MUST use the same model, or similarity search becomes meaningless.
    """
    vector = _model.encode(text, normalize_embeddings=True)
    return vector.tolist()