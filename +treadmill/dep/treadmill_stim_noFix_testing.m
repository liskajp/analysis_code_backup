function treadmill_stim_noFix(subj,inputType,viewdist,grbl_command) 
% inputType: 0 - eye tracking; 1 - mouse, 2 - keyboard press
% grbl_command: 0 - do nothing; 1 - home and move screen; 2 - move screen without homing (may break if not homed initially)
% default setting for subj name, input type, viewdist, and grbl_command

tic

IOPort closeall

if nargin == 0 
    subj = 'test';
end

if nargin < 1
    inputType = 1;
end

if nargin < 2 
    viewdist = 57.29;
end
    
if nargin < 4
    grbl_command = 0;
end

%% Creating the pldaps data struct 

load settingsStruct;


p = pldaps(@treadmill.treadmill_stim_setup,subj,settingsStruct);

p = pdsDefaultTrialStructure(p); 


p.trial.control = 0;

p.trial.display.scrnNum = 0;
% p.trial.display.screenSize = [0 0 1920 1080];
%p.trial.display.screenSize = [];
p.trial.display.screenSize = [0 0 160 90];
p.trial.display.frate = 60;


p.trial.display.viewdist = viewdist;
p.trial.stimulus.ipd = 6.5; % assume that all subject have a 65 mm IPD
p.trial.stimulus.eye = p.trial.stimulus.ipd .* [-.5 0; .5 0]; % set the two eye position 

p.trial.treadmill.use = 0;
p.trial.treadmill.port = '/dev/ttyUSB0';

p.trial.display.bgColor = [1 1 1].*0.001;
p.trial.display.clut.stimulus = abs(1 - p.trial.display.bgColor);


p.defaultParameters.display.ptr = 10;
p.defaultParameters.display.overlayptr = 11;
p.trial.display.useOverlay = 1;
p.trial.datapixx.use = 0;
% p.trial.sound.use = 1;
p.defaultParameters.display.useGL = 0;


p.trial.pldaps.pause.preExperiment = false;


p.trial.pldaps.trialMasterFunction = 'runModularTrial';
p.trial.pldaps.useModularStateFunctions = 1;

p.trial.stimulus.randomNumberGenerater = 'mt19937ar';


p.trial.inputType = inputType;
% present different inputs only show Fix and Targ windows with mouse
if(inputType == 0) 
    p.trial.eyelink.use = 0;
    p.trial.eyelink.useAsEyepos = 0;
    p.trial.mouse.useAsEyepos = 1;
    p.trial.pldaps.draw.cursor.showCursor = 1; 
    p.trial.stimulus.showTargWin = 0;
    p.trial.stimulus.showFixWin = 0;
    p.trial.pldaps.draw.eyepos.use = 0;
    
    
% elseif(inputType == 1)
%     p.trial.eyelink.use = 0;
%     p.trial.mouse.useAsEyepos = 1;
%     p.trial.pldaps.draw.cursor.showCursor = 1; 
%     p.trial.stimulus.showTargWin = 1;
%     p.trial.stimulus.showFixWin = 1;
%      
% elseif(inputType == 2) 
%     p.trial.eyelink.use = 0;
%     p.trial.mouse.useAsEyepos = 1;
%     p.trial.pldaps.draw.cursor.showCursor = 1; 
%     p.trial.stimulus.showTargWin = 1;
%     p.trial.stimulus.showFixWin = 1;
    
    device = PsychHID('Devices');
    for(i = 1:length(device))
        if(device(i).vendorID == 1444 && device(i).inputs == 271)
            p.trial.inputDev = i;
            break
        end
    end
    
    p.trial.pldaps.pause.preExperiment = false;
    
    
end


p.trial.adapt = 0;

%% Do you want to sync? 
Screen('Preference', 'SkipSyncTests', 0);

%% Initiate Treadmill
if (p.trial.treadmill.use == 1)
    p.trial.treadmill.location = 1;
    p.trial.treadmill.datapixx.isRunning = 0;
%    treadmill.tread_on(p,p.trial.treadmill.port)
    %need brake command in here somewhere (in the manual)
%     treadmill.CheckWorking
%         if treadmill.CheckWorking.IsWorking ~= 1
%             disp('Treadmill is not functioning! Check connection.');
%             stop;
%         end
end
%% Load in a big honkin' array of all the images
disp('Not frozen, just loading a lot of files...');
cd('/home/huklab/Documents/LowResShotsg');
clear allShots;
% load('allShots.mat');
% global allShots;
% p.trial.treadmill.ATU = length(allShots)/600;
p.trial.treadmill.shots = load('allShots.mat');
p.trial.treadmill.ATU = length(p.trial.treadmill.shots)/600;
disp('Done!');

%% run code 
p.run



toc

end