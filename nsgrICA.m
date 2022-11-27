
% MAT FILES NEEDED  interpolate160

eeglab; close;
filepath = [ pwd filesep ];
files = dir([filepath,filesep,'*.set']);

for k=1:length(files)

    % load dataset
    filename = files(k).name;
    EEG = pop_loadset(filename, filepath);

    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',45);
    EEG = pop_select(EEG,'nochannel',{'RH','LH','RTM','LTM','RBM','LBM','Snas'});
    EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan],'threshold',[-3 3],'norm','on','measure','spec','freqrange',[0.1 45] );
    EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan],'threshold',[-3 3],'norm','on','measure','spec','freqrange',[0.1 45] );

    EEGtemp = pop_eegfiltnew(EEG, 'locutoff',1);
    EEGtemp = pop_runica(EEGtemp, 'extended',1,'stop',1e-006,'maxsteps',1000000,'interupt','on');

    EEG.icaact = EEGtemp.icaact;
    EEG.icawinv = EEGtemp.icawinv;
    EEG.icaweigts = EEGtemp.icaweights;
    EEG.icachansind = EEGtemp.icachansind;
    EEG.icasphere = EEGtemp.icasphere;
    eeglab redraw

    EEG = pop_iclabel(EEG, 'default');
    ICLabel_Matrix = EEG.etc.ic_classification.ICLabel.classifications;
    %Columns of ICLabel_Matrix: brain,muscle,eye,heart,line,channel,others
    ICLabel_Matrix(:,8) = sum(ICLabel_Matrix(:,2:6),2);
    ICLabel_Matrix(:,9) = sum(ICLabel_Matrix(:,[1 7]),2);
    ind_ICs = find(ICLabel_Matrix(:,8)>0.5 & ICLabel_Matrix(:,1)<0.05);
    EEGrej = pop_subcomp( EEG, ind_ICs, 0);
    %EEG = interpolate160(EEG,mat);

    EEG = pop_saveset(filename, filepath);

end



