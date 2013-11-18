function [stimSeq,stimTime,eventSeq,colors]=mkStimSeq_flicker(h,duration,isi,periods,mkTarget)
if ( nargin<2 || isempty(duration) ) duration=3; end; % default to 3sec
if ( nargin<3 || isempty(isi) ) isi=2/60; end; % default to 60Hz
if ( nargin<4 || isempty(periods) ) periods=[2 4]; end;
if ( nargin<5 || isempty(mkTarget) ) mkTarget=true; end;
% make a simple visual intermittent flash stimulus
colors=[1 1 1;...;  % color(1) = flash
        0 1 0]';    % color(2) = target
stimTime=0:isi:duration; % event every isi
stimSeq =zeros(numel(h),numel(stimTime)); % make stimSeq where everything is in background state
stimSeq(2:end-1,:)=0; % turn-on only the central square
for stimi=1:numel(h)-1;
  cycle=[ones(floor(periods(stimi)/2),1);zeros(periods(stimi)-floor(periods(stimi)/2),1)]; % 1 cycle of the SSEP
  seq=repmat(cycle,1,ceil(numel(stimTime)/numel(cycle))); % enough for stimTime events
  stimSeq(stimi,:) = seq(1:numel(stimTime));
end
eventSeq=cell(numel(stimTime),1); % No events...

% add a target queue
if ( mkTarget )
  % Pick who is going to be the target
  tgt=randi(numel(h)-1);
  freqs=[]; for i=1:numel(periods); freqs(i) = 1/(periods(i)*isi); end;

  % every 1s we send a SSVEP event
  evTime=0:1:stimTime(end)-1;
  for i=1:numel(evTime); 
    [ans,si]=min(abs(stimTime-evTime(i))); % find nearest stim time
    eventSeq{si}={'stimulus',sprintf('SSVEP %g',freqs(tgt))};
  end

  stimTime=[0 stimTime+1];
  flashStim=-ones(numel(h),1); flashStim(1:end-1)=0; flashStim(tgt)=2; % tgt has 2 set
  stimSeq=cat(2,flashStim,stimSeq);
  eventSeq=cat(1,{{'stimulus.target',tgt}},eventSeq);
end

return;