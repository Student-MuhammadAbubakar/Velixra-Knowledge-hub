from typing import List
import numpy as np
from sqlalchemy.ext.asyncio import AsyncSession

from app.repositories import analytic_repo
from app.schemas import DocumentAnalytics, TopQuestion, OwnerAnalyticsResponse

SIMILARITY_THRESHOLD = 0.80  # cosine similarity above this = "same question, different wording"


def _cosine_similarity(vec_a: List[float], vec_b: List[float]) -> float:
    a = np.array(vec_a)
    b = np.array(vec_b)
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))


def _cluster_questions(logs: list) -> List[TopQuestion]:
    """
    Greedy clustering: walk through questions in order, grouping each one
    into the first existing cluster it's similar enough to, or starting
    a new cluster if nothing matches closely enough.
    """
    clusters: list[dict] = []  # each: {"representative": str, "embedding": list[float], "count": int}

    for log in logs:
        matched_cluster = None

        for cluster in clusters:
            similarity = _cosine_similarity(log.question_embedding, cluster["embedding"])
            if similarity >= SIMILARITY_THRESHOLD:
                matched_cluster = cluster
                break

        if matched_cluster:
            matched_cluster["count"] += 1
        else:
            clusters.append({
                "representative": log.question,
                "embedding": log.question_embedding,
                "count": 1,
            })

    # Sort by how often each cluster was asked, most frequent first
    clusters.sort(key=lambda c: c["count"], reverse=True)

    return [
        TopQuestion(question_cluster=c["representative"], times_asked=c["count"])
        for c in clusters
    ]


async def get_owner_analytics(session: AsyncSession, top_n: int = 10) -> OwnerAnalyticsResponse:
    stats = await analytic_repo.get_document_stats(session)
    document_stats = DocumentAnalytics(**stats)

    logs = await analytic_repo.get_recent_query_logs(session, limit=500)
    all_clusters = _cluster_questions(logs)
    top_questions = all_clusters[:top_n]

    return OwnerAnalyticsResponse(
        document_stats=document_stats,
        top_questions=top_questions,
    )