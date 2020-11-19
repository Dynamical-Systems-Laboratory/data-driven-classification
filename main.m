%% initialize variables

dataFolder = '/Users/ronibarakventura/Desktop/VR interface/Data';
codesFolder = '/Users/ronibarakventura/Desktop/VR interface/Analysis Codes';
PrincipalComponents = [];
numUsers = 9;
trainingData = [];
    
for userID = 1:9

%% open data
    
    movement = readtable(sprintf(strcat(dataFolder,'/User-%d.csv'),userID));
    cd(codesFolder); % move to codes' folder

    % find points where user practices unlocking the cursor to identify where movement starts from neutral
    presentationIndex = find(movement.Cursor_Moving==1,1);
    lockIndex1 = find(movement.Cursor_Moving(presentationIndex:end)==0,1)+presentationIndex-1; % index where the cursor locks before the user unlocked the controllers the first time
    unlockIndex1 = find(movement.Cursor_Moving(lockIndex1:end)==1,1)+lockIndex1-1; % index where the user unlocks the cursor for the first time
    relockIndex1 = find(movement.Cursor_Moving((unlockIndex1+1):end)==0,1)+unlockIndex1; % index where the controllers relocked automatically
    unlockIndex2 = find(movement.Cursor_Moving((relockIndex1+1):end)==1,1)+relockIndex1; % index where the user unlocks the controller the second time
    startIndex = find(movement.Cursor_Moving((unlockIndex2+1):end)==0,1)+unlockIndex2;; % index where the controllers relocked automatically and the calibration starts

    % unwrap head angle to account for circularism
    movement.Head_RotX = unwrap(movement.Head_RotX*pi/180)*180/pi;
    movement.Head_RotY = unwrap(movement.Head_RotY*pi/180)*180/pi;
    movement.Head_RotZ = unwrap(movement.Head_RotZ*pi/180)*180/pi;
    movement.Head_RotX = movement.Head_RotX-mean(movement.Head_RotX(startIndex:startIndex+1000));
    movement.Head_RotY = movement.Head_RotY-mean(movement.Head_RotY(startIndex:startIndex+1000));
    movement.Head_RotZ = movement.Head_RotZ-mean(movement.Head_RotZ(startIndex:startIndex+1000));

    movement.Head_PosX = fixPosition(movement.Head_PosX); % correct head position for circularism
    movement.Head_PosY = fixPosition(movement.Head_PosY);
    movement.Head_PosZ = fixPosition(movement.Head_PosZ);
    movement.Head_PosX = movement.Head_PosX-mean(movement.Head_PosX(startIndex:startIndex+1000));
    movement.Head_PosY = movement.Head_PosY-mean(movement.Head_PosY(startIndex:startIndex+1000));
    movement.Head_PosZ = movement.Head_PosZ-mean(movement.Head_PosZ(startIndex:startIndex+1000));


    % unwrap hand angles to account for circularism
    movement.RHand_RotX = unwrap(movement.RHand_RotX*pi/180)*180/pi; % correct hands angles for circularism
    movement.RHand_RotY = unwrap(movement.RHand_RotY*pi/180)*180/pi;
    movement.RHand_RotZ = unwrap(movement.RHand_RotZ*pi/180)*180/pi;
    movement.LHand_RotX = unwrap(movement.LHand_RotX*pi/180)*180/pi;
    movement.LHand_RotY = unwrap(movement.LHand_RotY*pi/180)*180/pi;
    movement.LHand_RotZ = unwrap(movement.LHand_RotZ*pi/180)*180/pi;
    movement.RHand_RotX = movement.RHand_RotX-mean(movement.RHand_RotX(startIndex:startIndex+1000));
    movement.RHand_RotY = movement.RHand_RotY-mean(movement.RHand_RotY(startIndex:startIndex+1000));
    movement.RHand_RotZ = movement.RHand_RotZ-mean(movement.RHand_RotZ(startIndex:startIndex+1000));
    movement.LHand_RotX = movement.LHand_RotX-mean(movement.LHand_RotX(startIndex:startIndex+1000));
    movement.LHand_RotY = movement.LHand_RotY-mean(movement.LHand_RotY(startIndex:startIndex+1000));
    movement.LHand_RotZ = movement.LHand_RotZ-mean(movement.LHand_RotZ(startIndex:startIndex+1000));

    movement.RHand_PosX = fixPosition(movement.RHand_PosX); % correct hands positions for circularism
    movement.RHand_PosY = fixPosition(movement.RHand_PosY);
    movement.RHand_PosZ = fixPosition(movement.RHand_PosZ);
    movement.LHand_PosX = fixPosition(movement.LHand_PosX);
    movement.LHand_PosY = fixPosition(movement.LHand_PosY);
    movement.LHand_PosZ = fixPosition(movement.LHand_PosZ);
    movement.RHand_PosX = movement.RHand_PosX-mean(movement.RHand_PosX(startIndex:startIndex+1000));
    movement.RHand_PosY = movement.RHand_PosY-mean(movement.RHand_PosY(startIndex:startIndex+1000));
    movement.RHand_PosZ = movement.RHand_PosZ-mean(movement.RHand_PosZ(startIndex:startIndex+1000));
    movement.LHand_PosX = movement.LHand_PosX-mean(movement.LHand_PosX(startIndex:startIndex+1000));
    movement.LHand_PosY = movement.LHand_PosY-mean(movement.LHand_PosY(startIndex:startIndex+1000));
    movement.LHand_PosZ = movement.LHand_PosZ-mean(movement.LHand_PosZ(startIndex:startIndex+1000));


%     figure % plot head position
%     plot(movement.Elapsed_Time,movement.Head_PosX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.Head_PosY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.Head_PosZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Position (m)','FontSize',20,'FontName','Arial');
%     legend('x_{h}','y_{h}','z_{h}')
% 
%     figure % plot head orientation
%     plot(movement.Elapsed_Time,movement.Head_RotX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.Head_RotY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.Head_RotZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Angle (deg)','FontSize',20,'FontName','Arial');
%     legend('\gamma_{h}','\beta_{h}','\alpha_{h}')
% 
%     figure % plot right hand orientation
%     plot(movement.Elapsed_Time,movement.RHand_RotX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.RHand_RotY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.RHand_RotZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Angle (deg)','FontSize',20,'FontName','Arial');
%     legend('\gamma_{R}','\beta_{R}','\alpha_{R}')
% 
%     figure % plot left hand orientation
%     plot(movement.Elapsed_Time,movement.LHand_RotX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.LHand_RotY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.LHand_RotZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Angle (deg)','FontSize',20,'FontName','Arial');
%     legend('\gamma_{L}','\beta_{L}','\alpha_{L}')
% 
%     figure % plot right hand position
%     plot(movement.Elapsed_Time,movement.RHand_PosX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.RHand_PosY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.RHand_PosZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Position (m)','FontSize',20,'FontName','Arial');
%     legend('x_{R}','y_{R}','z_{R}')
% 
%     figure % plot left hand position
%     plot(movement.Elapsed_Time,movement.LHand_PosX,'LineWidth',1,'Color',[0,170,255]/256)
%     hold
%     plot(movement.Elapsed_Time,movement.LHand_PosY,'LineWidth',1,'Color',[170,90,230]/256)
%     plot(movement.Elapsed_Time,movement.LHand_PosZ,'LineWidth',1,'Color',[255,170,0]/256)
%     a = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
%     set(gca,'XTickLabelMode','auto')
%     xlabel('Time (s)','FontSize',20,'FontName','Arial');
%     ylabel('Position (m)','FontSize',20,'FontName','Arial');
%     legend('x_{L}','y_{L}','z_{L}')


    %% apply transformations

    % empty arrays of positions of the arms relative to the head
    x_r=[];
    y_r=[];
    z_r=[];
    x_l=[];
    y_l=[];
    z_l=[];

    % empty arrays of orientations of the arms relative to the head
    a_r=[];
    b_r=[];
    g_r=[];
    a_l=[];
    b_l=[];
    g_l=[];

    for i =[1:length(movement.Head_RotZ)]

        % instantaneous homogeneous transformation matrices
        hRg = [eul2rotm([movement.Head_RotZ(i) movement.Head_RotY(i) movement.Head_RotX(i)]*pi/180) [movement.Head_PosX(i); movement.Head_PosY(i); movement.Head_PosZ(i)]; 0 0 0 1]; % position and orientation of the head relative to the global coordinates
        rRg = [eul2rotm([movement.RHand_RotZ(i) movement.RHand_RotY(i) movement.RHand_RotX(i)]*pi/180) [movement.RHand_PosX(i); movement.RHand_PosY(i); movement.RHand_PosZ(i)]; 0 0 0 1]; % position and orientation of the right hand relative to the global coordinates
        lRg = [eul2rotm([movement.LHand_RotZ(i) movement.LHand_RotY(i) movement.LHand_RotX(i)]*pi/180) [movement.LHand_PosX(i); movement.LHand_PosY(i); movement.LHand_PosZ(i)]; 0 0 0 1]; % position and orientation of the left hand relative to the global coordinates

        % compute instantaneous transformation from the right hand frame to the global frame
        hRr = hRg * inv(rRg);
        x_r = [x_r; hRr(1,end)];
        y_r = [y_r; hRr(2,end)];
        z_r = [z_r; hRr(3,end)];
        abg_r = rotm2eul(hRr(1:3,1:3))*180/pi;
        a_r = [a_r; abg_r(1)];
        b_r = [b_r; abg_r(2)];
        g_r = [g_r; abg_r(3)];

        % compute instantaneous transformation from the left hand frame to the global frame
        hRl = hRg * inv(lRg);
        x_l = [x_l; hRl(1,end)];
        y_l = [y_l; hRl(2,end)];
        z_l = [z_l; hRl(3,end)];
        abg_l = rotm2eul(hRl(1:3,1:3))*180/pi;
        a_l = [a_l; abg_l(1)];
        b_l = [b_l; abg_l(2)];
        g_l = [g_l; abg_l(3)];  

    end

    a_r = unwrap(a_r*pi/180)*180/pi;
    b_r = unwrap(b_r*pi/180)*180/pi;
    g_r = unwrap(g_r*pi/180)*180/pi;
    a_l = unwrap(a_l*pi/180)*180/pi;
    b_l = unwrap(b_l*pi/180)*180/pi;
    g_l = unwrap(g_l*pi/180)*180/pi;

    relativePositions = [x_r y_r z_r a_r b_r g_r x_l y_l z_l a_l b_l g_l];

    %% plot relative positions

    figure % plot right hand position
    plot(movement.Elapsed_Time,x_r,'LineWidth',1,'Color',[0,170,255]/256)
    hold
    plot(movement.Elapsed_Time,y_r,'LineWidth',1,'Color',[170,90,230]/256)
    plot(movement.Elapsed_Time,z_r,'LineWidth',1,'Color',[255,170,0]/256)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
    set(gca,'XTickLabelMode','auto')
    xlabel('Time (s)','FontSize',20,'FontName','Arial');
    ylabel('Position (m)','FontSize',20,'FontName','Arial');
    legend('x_{R}','y_{R}','z_{R}')

    figure % plot left hand position
    plot(movement.Elapsed_Time,x_l,'LineWidth',1,'Color',[0,170,255]/256)
    hold
    plot(movement.Elapsed_Time,y_l,'LineWidth',1,'Color',[170,90,230]/256)
    plot(movement.Elapsed_Time,z_l,'LineWidth',1,'Color',[255,170,0]/256)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
    set(gca,'XTickLabelMode','auto')
    xlabel('Time (s)','FontSize',20,'FontName','Arial');
    ylabel('Position (m)','FontSize',20,'FontName','Arial');
    legend('x_{L}','y_{L}','z_{L}')

    figure % plot right hand orientation
    plot(movement.Elapsed_Time,a_r,'LineWidth',1,'Color',[0,170,255]/256)
    hold
    plot(movement.Elapsed_Time,b_r,'LineWidth',1,'Color',[170,90,230]/256)
    plot(movement.Elapsed_Time,g_r,'LineWidth',1,'Color',[255,170,0]/256)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
    set(gca,'XTickLabelMode','auto')
    xlabel('Time (s)','FontSize',20,'FontName','Arial');
    ylabel('Angle (deg)','FontSize',20,'FontName','Arial');
    legend('\gamma_{R}','\beta_{R}','\alpha_{R}')

    figure % plot left hand orientation
    plot(movement.Elapsed_Time,a_l,'LineWidth',1,'Color',[0,170,255]/256)
    hold
    plot(movement.Elapsed_Time,b_l,'LineWidth',1,'Color',[170,90,230]/256)
    plot(movement.Elapsed_Time,g_l,'LineWidth',1,'Color',[255,170,0]/256)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontName','Arial')
    set(gca,'XTickLabelMode','auto')
    xlabel('Time (s)','FontSize',20,'FontName','Arial');
    ylabel('Angle (deg)','FontSize',20,'FontName','Arial');
    legend('\gamma_{L}','\beta_{L}','\alpha_{L}')


    %% segment data

    % Segmentation based on clicks in calibration
    calibrationIntervals = [find(diff(movement.Cursor_Moving((startIndex+1):end))==1,26) find(diff(movement.Cursor_Moving((startIndex+1):end))==-1,26)];

    % use velocities for segmentation since the angle values may be off by hundreds of degrees
    velocities = [diff(movement{startIndex:end,4:9},1) diff(relativePositions(startIndex:end,:),1)]; % velocities of the head and realtive velocities of the hands

    startEnd = [];
    for s = 1:25 % iterate through potential segments (there are 25 in the calibration
        
        int = calibrationIntervals(s,1):calibrationIntervals(s+1,1);
        z = sqrt((velocities(int,7).^2)+(velocities(int,8).^2)+(velocities(int,9).^2)+(velocities(int,13).^2)+(velocities(int,14).^2)+(velocities(int,15).^2)); % compute the average speed of the hands
        threshold = 0.006; % threshold for z where movement is considered as motion rather than noise
        
        figure % plot the chosen data points to ensure they are correct
        plot(z)
        hold
        scatter(find(z>threshold),z(find(z>threshold)))
        
        ind = find(z>threshold); % indices of the measurements that can potentially be movement
        dInd = find(diff(ind)>1); % indices of movement that are not consecutive
        for i=[2:length(dInd)] % iterate through indices

            if dInd(i)-dInd(i-1)<15 % if two potential instances of movement are less than 0.25 s apart
                ind(dInd(i-1):dInd(i)) = 0; % identify this instance as non-movement/noise
            end

        end
        ind(end) = 0;
        ind(find(ind==0))=[]; % remove all instance of falsely identified movement

        if isempty(ind) % if something went wrong and the movement was not recorded correctly
            next
        else
            startInd = calibrationIntervals(s,1)+ind(1);
            pauses = find(diff(ind)>30); % find the indices where the pause is longer than 1/6 s
            if size(pauses,1)>1 % if the user forgot to unlock the cursor
                endInd = calibrationIntervals(s,1)+ind(pauses(2));
            else
                endInd = calibrationIntervals(s,1)+ind(end);
            end

            startEnd = [startEnd; startInd endInd]; % matrix of segments start and end points
        end
    end
    
    
    % add true class to training data
    dataset = [velocities(1:startEnd(end,end)+1,1:6) relativePositions(startIndex:(startIndex+startEnd(end,end)),:) velocities(1:startEnd(end,end)+1,7:end)]; % head velocities; right and left hand relative positions; right and left hands relative velocities
    trainingData = [trainingData; [userID*(ones(size(dataset,1),1)) zeros(size(dataset,1),1) dataset]];

    for s = 1:size(startEnd,1)
        trainingData(startEnd(s,1):startEnd(s,2),2) = ceil(s/5);
    end
    

    %% principal components analysis

    
    for s = [1:size(startEnd,1)] % iterate through segments

        seg = dataset(startEnd(s,1):startEnd(s,2),:);

        % standardize the variables
        for v = 1:size(seg,2)
           seg(:,v) = seg(:,v)-mean(seg(:,v))./std(seg(:,v));
        end

        % create covariance matrix
        covMat = nan(size(seg,2));
        for i = 1:size(seg,2)
            for j = 1:size(seg,2)
                covar = cov(seg(:,i),seg(:,j));
                covMat(i,j) = covar(1,2);
            end
        end

        [eigvec,eigval] = eig(covMat);
        [eigval,I] = sort(sum(eigval),'descend');
        eigvec = eigvec(:,I);

        % plot eigenvalues
        figure 
        scatter(1:size(eigval,2),[eigval], 40,'black','filled')
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',12,'FontName','Arial')
        set(gca,'XTickLabelMode','auto')
        xlabel('\it i','FontSize',20,'FontName','Arial');
        ylabel('\it \lambda_{i}','FontSize',20,'FontName','Arial');

        % plot eigenvalues and spectral gap
        gap = find(diff(eigval)==min(diff(eigval)));
        line([gap+0.5 gap+0.5], get(gca, 'ylim'),'LineStyle','--','Color','black');% add dashed line for gap   

        % plot components of eigenvector
        for ev = 1:gap % iterate through prominent eigenvectors

            [components,componentOrder] = sort(abs(eigvec(:,ev)),'descend');

            figure % plot eigenvectors
            a = get(gca,'XTickLabel');
            set(gca,'XTickLabel',a,'fontsize',12,'FontName','Arial')
            set(gca,'XTickLabelMode','auto')
            xlabel('\it i','FontSize',20,'FontName','Arial');
            ylabel('\it \nu_{i}','FontSize',20,'FontName','Arial');

            hold
            for c = 1:size(seg,2) % iterate through components

                % head is blue
                if ismember(componentOrder(c),[1:6])

                    clr = [80,190,250]/256; % color blue
                    % position symbols are filled
                    if componentOrder(c)==1
                        scatter(c,components(c),40,clr,'o','filled')
                    elseif componentOrder(c)==2
                        scatter(c,components(c),40,clr,'^','filled')
                    elseif componentOrder(c)==3
                        scatter(c,components(c),50,clr,'s','filled')

                    % angle symbols are empty
                    elseif componentOrder(c)==4
                        scatter(c,components(c),40,clr,'o')
                    elseif componentOrder(c)==5
                        scatter(c,components(c),40,clr,'^')
                    elseif componentOrder(c)==6
                        scatter(c,components(c),50,clr,'s')
                    end


                % right hand relative position is orange    
                elseif ismember(componentOrder(c),[7:12]) 

                    clr = [255,170,0]/256; % color orange
                    % position symbols are filled
                    if componentOrder(c)==7
                        scatter(c,components(c),40,clr,'o','filled')
                    elseif componentOrder(c)==8
                        scatter(c,components(c),40,clr,'^','filled')
                    elseif componentOrder(c)==9
                        scatter(c,components(c),50,clr,'s','filled')

                    % rotation symbols are empty
                    elseif componentOrder(c)==10
                        scatter(c,components(c),40,clr,'o')
                    elseif componentOrder(c)==11
                        scatter(c,components(c),40,clr,'^')
                    elseif componentOrder(c)==12
                        scatter(c,components(c),50,clr,'s')
                    end

                % left arm relative positionis purple
                elseif ismember(componentOrder(c),[13:18]) 

                    clr = [170,90,230]/256; % color purple
                    % position symbols are filled                
                    if componentOrder(c)==13
                        scatter(c,components(c),40,clr,'o','filled')
                    elseif componentOrder(c)==14
                        scatter(c,components(c),40,clr,'^','filled')
                    elseif componentOrder(c)==15
                        scatter(c,components(c),50,clr,'s','filled')

                    % velocity symbols are empty
                    elseif componentOrder(c)==16
                        scatter(c,components(c),40,clr,'o')
                    elseif componentOrder(c)==17
                        scatter(c,components(c),40,clr,'^')
                    elseif componentOrder(c)==18
                        scatter(c,components(c),50,clr,'s')
                    end

                % relative right hand speed is pink    
                elseif ismember(componentOrder(c),[19:24]) 

                    clr = [256,150,200]/256; % color orange
                    % position symbols are filled
                    if componentOrder(c)==19
                        scatter(c,components(c),40,clr,'o','filled')
                    elseif componentOrder(c)==20
                        scatter(c,components(c),40,clr,'^','filled')
                    elseif componentOrder(c)==21
                        scatter(c,components(c),50,clr,'s','filled')

                    % rotation symbols are empty
                    elseif componentOrder(c)==22
                        scatter(c,components(c),40,clr,'o')
                    elseif componentOrder(c)==23
                        scatter(c,components(c),40,clr,'^')
                    elseif componentOrder(c)==24
                        scatter(c,components(c),50,clr,'s')
                    end

                % relative left hand speed is green    
                elseif ismember(componentOrder(c),[25:30]) 

                    clr = [125,200,125]/256; % color green
                    % position symbols are filled
                    if componentOrder(c)==25
                        scatter(c,components(c),40,clr,'o','filled')
                    elseif componentOrder(c)==26
                        scatter(c,components(c),40,clr,'^','filled')
                    elseif componentOrder(c)==27
                        scatter(c,components(c),50,clr,'s','filled')

                    % rotation symbols are empty
                    elseif componentOrder(c)==28
                        scatter(c,components(c),40,clr,'o')
                    elseif componentOrder(c)==29
                        scatter(c,components(c),40,clr,'^')
                    elseif componentOrder(c)==30
                        scatter(c,components(c),50,clr,'s')
                    end

                end

                % plot spectral gap
                gap = find(diff(components)==min(diff(components)));
                line([gap+0.5 gap+0.5], get(gca, 'ylim'),'LineStyle','--','Color','black');% add dashed line for gap   

            end
            add results to a table
            PrincipalComponents = [PrincipalComponents; userID s ev gap transpose(componentOrder); NaN NaN NaN NaN transpose(components)];

        end    
    end


end % finish iterating through users

PrincipalComponents = array2table(PrincipalComponents,'VariableNames',{'userID','segment','Lambda','NumImportantComponents','Nu1','Nu2','Nu3','Nu4','Nu5','Nu6','Nu7','Nu8','Nu9','Nu10','Nu11','Nu12','Nu13','Nu14','Nu15','Nu16','Nu17','Nu18','Nu19','Nu20','Nu21','Nu22','Nu23','Nu24','Nu25','Nu26','Nu27','Nu28','Nu29','Nu30'});
writetable(PrincipalComponents,'/Users/ronibarakventura/Desktop/PCA.csv')

trainingData = array2table(trainingData,'VariableNames',{'userID','trueClass','Head_VelX','Head_VelY','Head_VelZ','Head_VelG','Head_VelB','Head_VelA','RTouch_RelVelX','RTouch_RelVelY','RTouch_RelVelZ','RTouch_RelVelG','RTouch_RelVelB','RTouch_RelVelA','LTouch_RelVelX','LTouch_RelVelY','LTouch_RelVelZ','LTouch_RelVelG','LTouch_RelVelB','LTouch_RelVelA','RTouch_VelX','RTouch_VelY','RTouch_VelZ','RTouch_VelG','RTouch_VelB','RTouch_VelA','LTouch_VelX','LTouch_VelY','LTouch_VelZ','LTouch_VelG','LTouch_VelB','LTouch_VelA'});
writetable(trainingData,'/Users/ronibarakventura/Desktop/trainingData.csv')


%% identify salient variables

PCA_R = [];
PCA_L = [];
PCA_U = [];
PCA_D = [];
PCA_F = [];

for u = 1:numUsers % iterate through users 
    for s = 1:25 % iterate through segments
        for l = intersect(find(PrincipalComponents.userID == u),find(PrincipalComponents.segment == ceil(s/2)))
            
            v = PrincipalComponents{l,5:(4+PrincipalComponents.NumImportantComponents(l))};
            % add to the list of salient variables
            
            if ismember(l,1:5)
                PCA_R = union(PCA_R,v);
            elseif ismember(l,6:10)
                PCA_L = union(PCA_L,v);
            elseif ismember(l,11:15)
                PCA_U = union(PCA_U,v);
            elseif ismember(l,16:20)
                PCA_D = union(PCA_D,v);
            elseif ismember(l,21:25)
                PCA_F = union(PCA_F,v);
            end
            
        end
    end
end


    %% define true classes for moving frames

    fs = 13; % size of a moving frame
    trueFrames = [];
    features = [];
    for userID = 1:numUsers
        
        subsetData = trainingData(find(trainingData.userID == userID),:);
        
        for s = 1:size(subsetData,1)-fs

           trueFrames = [trueFrames; mode(subsetData.trueClass(s:s+fs))];

           % means of relative positions
           m1 = mean(subsetData{s:s+fs,9});
           m2 = mean(subsetData{s:s+fs,10});
           m3 = mean(subsetData{s:s+fs,11});
           m4 = mean(subsetData{s:s+fs,12});
           m5 = mean(subsetData{s:s+fs,13});
           m6 = mean(subsetData{s:s+fs,14});
           m7 = mean(subsetData{s:s+fs,15});
           m8 = mean(subsetData{s:s+fs,16});
           m9 = mean(subsetData{s:s+fs,17});
           m10 = mean(subsetData{s:s+fs,18});
           m11 = mean(subsetData{s:s+fs,19});
           m12 = mean(subsetData{s:s+fs,20});

           r1 = range(subsetData{s:s+fs,12});
           r2 = range(subsetData{s:s+fs,13});
           r3 = range(subsetData{s:s+fs,14});
           r4 = range(subsetData{s:s+fs,18});
           r5 = range(subsetData{s:s+fs,19});
           r6 = range(subsetData{s:s+fs,20});

           s1 = std(subsetData{s:s+fs,12});
           s2 = std(subsetData{s:s+fs,13});   
           s3 = std(subsetData{s:s+fs,14});
           s4 = std(subsetData{s:s+fs,18});   
           s5 = std(subsetData{s:s+fs,19});
           s6 = std(subsetData{s:s+fs,20});   


           cov1011 = cov(subsetData{s:s+fs,12},subsetData{s:s+fs,13});
           cov1011 = cov1011(1,2);
           cov1012 = cov(subsetData{s:s+fs,12},subsetData{s:s+fs,14});
           cov1012 = cov1012(1,2);   
           cov1112 = cov(subsetData{s:s+fs,13},subsetData{s:s+fs,14});
           cov1112 = cov1112(1,2);
           cov1617 = cov(subsetData{s:s+fs,18},subsetData{s:s+fs,19});
           cov1617 = cov1617(1,2);
           cov1618 = cov(subsetData{s:s+fs,18},subsetData{s:s+fs,20});
           cov1618 = cov1618(1,2);   
           cov1718 = cov(subsetData{s:s+fs,19},subsetData{s:s+fs,20});
           cov1718 = cov1718(1,2);   
           cov1016 = cov(subsetData{s:s+fs,12},subsetData{s:s+fs,18});
           cov1016 = cov1016(1,2);   
           cov1018 = cov(subsetData{s:s+fs,12},subsetData{s:s+fs,20});
           cov1018 = cov1018(1,2); 
           cov1216 = cov(subsetData{s:s+fs,14},subsetData{s:s+fs,18});
           cov1216 = cov1216(1,2);      
           cov1218 = cov(subsetData{s:s+fs,14},subsetData{s:s+fs,20});
           cov1218 = cov1218(1,2);     
           cov1117 = cov(subsetData{s:s+fs,13},subsetData{s:s+fs,19});
           cov1117 = cov1117(1,2);      
           cov1118 = cov(subsetData{s:s+fs,13},subsetData{s:s+fs,20});
           cov1118 = cov1118(1,2);     


           features = [features;  m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 r1 r2 r3 r4 r5 r6 s1 s2 s3 s4 s5 s6 cov1011 cov1012 cov1112 cov1617 cov1618 cov1718 cov1016 cov1018 cov1216 cov1218 cov1117 cov1118];
        end
    end
    

    %% Classification algorithm
    ML_Data = [trueFrames features];
    ML_Data = array2table(ML_Data,'VariableNames',{'trueClass','m1','m2','m3','m4','m5','m6','m7','m8','m9','m10','m11','m12','r1','r2','r3','r4','r5','r6','s1','s2','s3','s4','s5','s6','cov1011','cov1012','cov1112','cov1617','cov1618','cov1718','cov1016','cov1018','cov1216','cov1218','cov1117','cov1118'});

    Importance = oobPermutedPredictorImportance(baggedTrees.ClassificationEnsemble)
    figure
    bar(Importance)