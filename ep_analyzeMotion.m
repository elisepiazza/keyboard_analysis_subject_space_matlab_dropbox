%ep_analyzeMotion
%For each subject, for each run, analyze amount of motion in x y z roll
%pitch yaw (not sure about the order of the last 3)

clear;
cd('/Users/elise/Dropbox/fMRI_music/keyboard_main/fMRI/analysis/');
subjects = [101 102 103 104 105 108 110 115 120]; nSubs = length(subjects);

nRuns = [23 8 18 16 18 18 18 20 18];
headcase = {[1:23] [1:8] [] [1:6] [1:18] [] [] [] []}; %in which runs did we use the headcase?

filepath = '../motion/';

for s = 1:nSubs
    
    for r = 1:nRuns(s)
        
        %Load the motion txt file for this run
        motion = load([filepath num2str(subjects(s)) '/r' num2str(r) '.txt']);
        
        if ismember(r,headcase{s})
            headcase_tag = 'headcase';
        else
            headcase_tag = 'no headcase';
        end
        
        %Plot the 6-D motion across TRs
        figure('Units', 'pixels', 'Position', [100 100 1000 375]);
        plot(1:size(motion,1), motion, 'LineWidth', 2);
        xlabel('TR'); ylabel('Displacement (?)'); title(['Subject ' num2str(subjects(s)) ', Run ' num2str(r) ', ' headcase_tag]); ylim([-3 3]); set(gca, 'FontSize', 16); legend('x', 'y', 'z', 'roll', 'pitch', 'yaw');
        print(gcf, '-dtiff', ['../figures/motion/s' num2str(subjects(s)) '_run' num2str(r) '_' headcase_tag '.tif']);

    end
 
end

       
