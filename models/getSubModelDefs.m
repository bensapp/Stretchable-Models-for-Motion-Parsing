function [s] = getSubModelDefs()
%%

% each struct defines what the temporal root is, and what the WITHIN FRAME
% child of each variable is, for each of the six variables

% there are 12 submodels
% naming scheme:
% submodels.(persistence_part).(tracking_part)

% submodels.elbow.luarm.root = 'luarm';
% submodels.elbow.luarm.luarm = {'llarm'};
% submodels.elbow.luarm.llarm = {'lhand', 'rlarm'};
% submodels.elbow.luarm.lhand = {};
% submodels.elbow.luarm.ruarm = {};
% submodels.elbow.luarm.rlarm = {'rhand', 'ruarm'};
% submodels.elbow.luarm.rhand = {};

submodels.elbow.llarm.root = 'llarm';
submodels.elbow.llarm.luarm = {};
submodels.elbow.llarm.llarm = {'luarm','lhand', 'rlarm'};
submodels.elbow.llarm.lhand = {};
submodels.elbow.llarm.ruarm = {};
submodels.elbow.llarm.rlarm = {'rhand', 'ruarm'};
submodels.elbow.llarm.rhand = {};

% submodels.elbow.lhand.root = 'lhand';
% submodels.elbow.lhand.luarm = {};
% submodels.elbow.lhand.llarm = {'luarm','rlarm'};
% submodels.elbow.lhand.lhand = {'llarm'};
% submodels.elbow.lhand.ruarm = {};
% submodels.elbow.lhand.rlarm = {'rhand', 'ruarm'};
% submodels.elbow.lhand.rhand = {};
% 
% submodels.elbow.ruarm.root = 'ruarm';
% submodels.elbow.ruarm.luarm = {};
% submodels.elbow.ruarm.llarm = {'luarm','lhand'};
% submodels.elbow.ruarm.lhand = {};
% submodels.elbow.ruarm.ruarm = {'rlarm'};
% submodels.elbow.ruarm.rlarm = {'rhand', 'llarm'};
% submodels.elbow.ruarm.rhand = {};

submodels.elbow.rlarm.root = 'rlarm';
submodels.elbow.rlarm.luarm = {};
submodels.elbow.rlarm.llarm = {'luarm','lhand'};
submodels.elbow.rlarm.lhand = {};
submodels.elbow.rlarm.ruarm = {};
submodels.elbow.rlarm.rlarm = {'ruarm','rhand', 'llarm'};
submodels.elbow.rlarm.rhand = {};

% submodels.elbow.rhand.root = 'rhand';
% submodels.elbow.rhand.luarm = {};
% submodels.elbow.rhand.llarm = {'luarm', 'lhand'};
% submodels.elbow.rhand.lhand = {};
% submodels.elbow.rhand.ruarm = {};
% submodels.elbow.rhand.rlarm = {'ruarm', 'llarm'};
% submodels.elbow.rhand.rhand = {'rlarm'};

% todo: submodels.hand.xxxxx

submodels.hand.lhand.root = 'lhand';
submodels.hand.lhand.luarm = {};
submodels.hand.lhand.llarm = {'luarm'};
submodels.hand.lhand.lhand = {'llarm', 'rhand'};
submodels.hand.lhand.ruarm = {};
submodels.hand.lhand.rlarm = {'ruarm'};
submodels.hand.lhand.rhand = {'rlarm'};

submodels.hand.rhand.root = 'rhand';
submodels.hand.rhand.luarm = {};
submodels.hand.rhand.llarm = {'luarm'};
submodels.hand.rhand.lhand = {'llarm'};
submodels.hand.rhand.ruarm = {};
submodels.hand.rhand.rlarm = {'ruarm'};
submodels.hand.rhand.rhand = {'rlarm', 'lhand'};

% shoulder persistence

submodels.shoulder.luarm.root = 'luarm';
submodels.shoulder.luarm.luarm = {'llarm','ruarm'};
submodels.shoulder.luarm.llarm = {'lhand'};
submodels.shoulder.luarm.lhand = {};
submodels.shoulder.luarm.ruarm = {'rlarm'};
submodels.shoulder.luarm.rlarm = {'rhand'};
submodels.shoulder.luarm.rhand = {};

submodels.shoulder.ruarm.root = 'ruarm';
submodels.shoulder.ruarm.luarm = {'llarm'};
submodels.shoulder.ruarm.llarm = {'lhand'};
submodels.shoulder.ruarm.lhand = {};
submodels.shoulder.ruarm.ruarm = {'rlarm','luarm'};
submodels.shoulder.ruarm.rlarm = {'rhand'};
submodels.shoulder.ruarm.rhand = {};

s(1) = submodels.shoulder.luarm;
s(2) = submodels.shoulder.ruarm;
s(3) = submodels.elbow.llarm;
s(4) = submodels.elbow.rlarm;
s(5) = submodels.hand.lhand;
s(6) = submodels.hand.rhand;

return






