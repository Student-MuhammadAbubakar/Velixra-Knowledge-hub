from enum import Enum
class UserRole(str,Enum):
    OWNER="owner"
    MANAGER="manager"
    EMPLOYEE="employee"
class Document_Process(str,Enum):
    PENDING="pending"
    READY="ready"
    PROCESSING="processing"
    FAILED="failed"
class Invitation_Status(str,Enum):
    PENDING="pending"
    ACCEPTED="accepted"
    EXPIRED="expired"
class Document_Status(str,Enum):
    PUBLIC="public"
    RESTRICTED="restricted"
class Invitation_Role(str,Enum):
    MANAGER="manager"
    EMPLOYEE="employee"
class MessageRole(str,Enum):
    USER="user"
    ASSISTANT="assistant"