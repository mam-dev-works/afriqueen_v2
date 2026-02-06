### Main System:
i iwant to ask how the match system is working here in short, sometime i saw the cards and sometime i don't see anything. why is this ? i couldnot understand whats happening in the match screen.

Short answer: the Match screen shows cards only when MatchBloc emits non‑empty data. It often ends up empty because of filters and exclusions.

How it works (brief):

CardScreen triggers MatchUsersFetched on entry.
MatchBloc loads users via HomeRepository.fetchAllExceptCurrentUser, then filters out:
favorites (FavoriteRepository)
archives (ArchiveRepository)
blocked users (BlockedRepository)
the current user
If nothing remains, it emits MatchDataEmpty, and the UI shows “no data”.
Why you sometimes see nothing:

After filtering, the list is empty.
If your favorites/archives/blocked lists are large (or filters hide most users), the match list can be empty.
Relevant files:

card_screen.dart
match_bloc.dart
match_state.dart
home_repository.dart