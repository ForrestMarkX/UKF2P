Class xVotingHandlerBase extends Info
	abstract;

function ClientDownloadInfo( xVotingReplication V );
function ClientCastVote( xVotingReplication V, int GameIndex, int MapIndex, bool bAdminForce );
function ClientRankMap( xVotingReplication V, bool bUp );
function ClientDisconnect( xVotingReplication V );
function ShowMapVote( PlayerController PC );
