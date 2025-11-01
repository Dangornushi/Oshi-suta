"""
Firestore repository for data persistence.

This module provides an abstraction layer for Firestore database operations.
"""

import logging
from datetime import datetime
from typing import Optional, List, Dict, Any
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

logger = logging.getLogger(__name__)


class FirestoreRepository:
    """Repository for managing Firestore database operations."""

    def __init__(self, db: firestore.Client):
        """
        Initialize FirestoreRepository.

        Args:
            db: Firestore client instance
        """
        self.db = db
        self.users_collection = "users"
        self.clubs_collection = "clubs"
        self.steps_collection = "steps"
        self.step_logs_subcollection = "step_logs"

    # ========== User Operations ==========

    async def create_user(self, user_id: str, data: Dict[str, Any]) -> None:
        """
        Create a new user document.

        Args:
            user_id: Unique user identifier
            data: User data dictionary
        """
        try:
            data["created_at"] = datetime.now()
            data["updated_at"] = datetime.now()
            self.db.collection(self.users_collection).document(user_id).set(data)
            logger.info(f"Created user: {user_id}")
        except Exception as e:
            logger.error(f"Error creating user {user_id}: {str(e)}")
            raise

    async def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve user data by ID.

        Args:
            user_id: User identifier

        Returns:
            User data dictionary or None if not found
        """
        try:
            doc = self.db.collection(self.users_collection).document(user_id).get()
            if doc.exists:
                return doc.to_dict()
            return None
        except Exception as e:
            logger.error(f"Error getting user {user_id}: {str(e)}")
            raise

    async def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve user data by email.

        Args:
            email: User email address

        Returns:
            User data dictionary or None if not found
        """
        try:
            users_ref = self.db.collection(self.users_collection)
            query = users_ref.where(filter=FieldFilter("email", "==", email)).limit(1)
            docs = query.stream()

            for doc in docs:
                data = doc.to_dict()
                data["user_id"] = doc.id
                return data

            return None
        except Exception as e:
            logger.error(f"Error getting user by email {email}: {str(e)}")
            raise

    async def update_user(self, user_id: str, data: Dict[str, Any]) -> None:
        """
        Update user data.

        Args:
            user_id: User identifier
            data: Updated user data
        """
        try:
            data["updated_at"] = datetime.now()
            self.db.collection(self.users_collection).document(user_id).update(data)
            logger.info(f"Updated user: {user_id}")
        except Exception as e:
            logger.error(f"Error updating user {user_id}: {str(e)}")
            raise

    async def increment_user_points(self, user_id: str, points: int) -> None:
        """
        Increment user's total points atomically.

        Args:
            user_id: User identifier
            points: Points to add
        """
        try:
            user_ref = self.db.collection(self.users_collection).document(user_id)
            user_ref.update({
                "total_points": firestore.Increment(points),
                "updated_at": datetime.now()
            })
            logger.info(f"Incremented {points} points for user {user_id}")
        except Exception as e:
            logger.error(f"Error incrementing points for user {user_id}: {str(e)}")
            raise

    # ========== Club Operations ==========

    async def get_club(self, club_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve club data by ID.

        Args:
            club_id: Club identifier

        Returns:
            Club data dictionary or None if not found
        """
        try:
            doc = self.db.collection(self.clubs_collection).document(club_id).get()
            if doc.exists:
                return doc.to_dict()
            return None
        except Exception as e:
            logger.error(f"Error getting club {club_id}: {str(e)}")
            raise

    async def get_all_clubs(self) -> List[Dict[str, Any]]:
        """
        Retrieve all clubs.

        Returns:
            List of club data dictionaries
        """
        try:
            clubs = []
            docs = self.db.collection(self.clubs_collection).stream()
            for doc in docs:
                club_data = doc.to_dict()
                club_data["club_id"] = doc.id
                clubs.append(club_data)
            return clubs
        except Exception as e:
            logger.error(f"Error getting all clubs: {str(e)}")
            raise

    async def update_club(self, club_id: str, data: Dict[str, Any]) -> None:
        """
        Update club data.

        Args:
            club_id: Club identifier
            data: Updated club data
        """
        try:
            self.db.collection(self.clubs_collection).document(club_id).update(data)
            logger.info(f"Updated club: {club_id}")
        except Exception as e:
            logger.error(f"Error updating club {club_id}: {str(e)}")
            raise

    async def increment_club_points(self, club_id: str, points: int) -> None:
        """
        Increment club's total points atomically.

        Args:
            club_id: Club identifier
            points: Points to add
        """
        try:
            club_ref = self.db.collection(self.clubs_collection).document(club_id)
            club_ref.update({
                "total_points": firestore.Increment(points)
            })
            logger.info(f"Incremented {points} points for club {club_id}")
        except Exception as e:
            logger.error(f"Error incrementing points for club {club_id}: {str(e)}")
            raise

    # ========== Step Log Operations ==========

    async def save_step_log(
        self,
        user_id: str,
        date: str,
        steps: int,
        points: int,
        source: str,
        device_signature: str
    ) -> None:
        """
        Save step log for a user.

        Args:
            user_id: User identifier
            date: Date string (YYYY-MM-DD)
            steps: Number of steps
            points: Points earned
            source: Data source (healthkit/googlefit)
            device_signature: Device identifier
        """
        try:
            log_data = {
                "user_id": user_id,
                "date": date,
                "steps": steps,
                "points": points,
                "source": source,
                "device_signature": device_signature,
                "created_at": datetime.now()
            }

            # Use date as document ID for easy duplicate checking
            doc_id = f"{user_id}_{date}"
            self.db.collection(self.steps_collection).document(doc_id).set(log_data)
            logger.info(f"Saved step log for user {user_id} on {date}")
        except Exception as e:
            logger.error(f"Error saving step log for user {user_id}: {str(e)}")
            raise

    async def get_step_log(self, user_id: str, date: str) -> Optional[Dict[str, Any]]:
        """
        Get step log for a specific date.

        Args:
            user_id: User identifier
            date: Date string (YYYY-MM-DD)

        Returns:
            Step log data or None if not found
        """
        try:
            doc_id = f"{user_id}_{date}"
            doc = self.db.collection(self.steps_collection).document(doc_id).get()
            if doc.exists:
                return doc.to_dict()
            return None
        except Exception as e:
            logger.error(f"Error getting step log for user {user_id} on {date}: {str(e)}")
            raise

    async def get_user_step_history(
        self,
        user_id: str,
        limit: int = 30
    ) -> List[Dict[str, Any]]:
        """
        Get user's step history.

        Args:
            user_id: User identifier
            limit: Maximum number of records to return

        Returns:
            List of step log dictionaries
        """
        try:
            steps_ref = self.db.collection(self.steps_collection)
            query = (
                steps_ref
                .where(filter=FieldFilter("user_id", "==", user_id))
                .order_by("date", direction=firestore.Query.DESCENDING)
                .limit(limit)
            )

            history = []
            docs = query.stream()
            for doc in docs:
                history.append(doc.to_dict())

            return history
        except Exception as e:
            logger.error(f"Error getting step history for user {user_id}: {str(e)}")
            raise

    async def get_club_members_count(self, club_id: str) -> int:
        """
        Get count of active members for a club.

        Args:
            club_id: Club identifier

        Returns:
            Number of active members
        """
        try:
            users_ref = self.db.collection(self.users_collection)
            query = users_ref.where(filter=FieldFilter("club_id", "==", club_id))
            docs = list(query.stream())
            return len(docs)
        except Exception as e:
            logger.error(f"Error getting member count for club {club_id}: {str(e)}")
            raise

    # ========== Player Operations ==========

    async def get_all_players(self, club_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieve all players or players from a specific club.

        Args:
            club_id: Optional club identifier to filter players

        Returns:
            List of player data dictionaries
        """
        try:
            players_ref = self.db.collection("players")

            if club_id:
                query = players_ref.where(filter=FieldFilter("club_id", "==", club_id))
            else:
                query = players_ref

            players = []
            docs = query.stream()
            for doc in docs:
                player_data = doc.to_dict()
                player_data["player_id"] = doc.id
                players.append(player_data)

            return players
        except Exception as e:
            logger.error(f"Error getting players: {str(e)}")
            raise

    async def get_player(self, player_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve player data by ID.

        Args:
            player_id: Player identifier

        Returns:
            Player data dictionary or None if not found
        """
        try:
            doc = self.db.collection("players").document(player_id).get()
            if doc.exists:
                player_data = doc.to_dict()
                player_data["player_id"] = doc.id
                return player_data
            return None
        except Exception as e:
            logger.error(f"Error getting player {player_id}: {str(e)}")
            raise

    # ========== Match Operations ==========

    async def get_all_matches(
        self,
        club_id: Optional[str] = None,
        season: Optional[int] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Retrieve matches with optional filters.

        Args:
            club_id: Optional club identifier to filter matches
            season: Optional season year to filter matches
            limit: Maximum number of matches to return

        Returns:
            List of match data dictionaries
        """
        try:
            matches_ref = self.db.collection("matches")
            query = matches_ref

            if season:
                query = query.where(filter=FieldFilter("season", "==", season))

            if club_id:
                # Match where club is either home or away
                # Note: Firestore doesn't support OR queries directly,
                # so we need to fetch both and merge
                home_query = query.where(filter=FieldFilter("home_club_id", "==", club_id)).limit(limit)
                away_query = query.where(filter=FieldFilter("away_club_id", "==", club_id)).limit(limit)

                matches = []
                match_ids = set()

                # Get matches where club is home
                for doc in home_query.stream():
                    if doc.id not in match_ids:
                        match_data = doc.to_dict()
                        match_data["match_id"] = doc.id
                        matches.append(match_data)
                        match_ids.add(doc.id)

                # Get matches where club is away
                for doc in away_query.stream():
                    if doc.id not in match_ids:
                        match_data = doc.to_dict()
                        match_data["match_id"] = doc.id
                        matches.append(match_data)
                        match_ids.add(doc.id)

                # Sort by date descending
                matches.sort(key=lambda x: x.get("date", ""), reverse=True)
                return matches[:limit]
            else:
                # No club filter, just get all matches
                query = query.order_by("date", direction=firestore.Query.DESCENDING).limit(limit)
                matches = []
                for doc in query.stream():
                    match_data = doc.to_dict()
                    match_data["match_id"] = doc.id
                    matches.append(match_data)
                return matches

        except Exception as e:
            logger.error(f"Error getting matches: {str(e)}")
            raise

    async def get_match(self, match_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve match data by ID.

        Args:
            match_id: Match identifier

        Returns:
            Match data dictionary or None if not found
        """
        try:
            doc = self.db.collection("matches").document(match_id).get()
            if doc.exists:
                match_data = doc.to_dict()
                match_data["match_id"] = doc.id
                return match_data
            return None
        except Exception as e:
            logger.error(f"Error getting match {match_id}: {str(e)}")
            raise
