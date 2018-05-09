clear all;
close all;
chiller_eff=xlsread('Final-Exam-Efficiency-Maps.xlsx','Sheet1');
pump_eff=xlsread('Final-Exam-Efficiency-Maps.xlsx','Pump Map');
head_mat = load('head.mat');
head_mat = head_mat.head;
flow_mat = load('flow.mat');
flow_mat = flow_mat.flow;
eff_pump_mat= load('efficiency.mat');
eff_pump_mat= eff_pump_mat.eff;
rpm_mat= load('rpm.mat');
rpm_mat= rpm_mat.RPM_fit;
% [chill_eff]
%% input
AHU6_Load_vec = [1884 1550  1100 400];
CHWSTSP_vec(1,:)=[38     40   42  44   46    48];
CHWRT_ref(1,:)  =[55     54.6 53.8 53.1 52.3 50.7];
CHWSTSP_vec(2,:)=[38     40   42  44   46    48];
CHWRT_ref(2,:)  =[54.5   55 54.7 53.9  53   51.7];
CHWSTSP_vec(3,:)=[38     40   42  44   46    48];
CHWRT_ref(3,:)  =[53.6   53.6 53.8 54.5 53.7 52.6];
CHWSTSP_vec(4,:)=[38     40   42  44   46    48];
CHWRT_ref(4,:)  =[49.9   50.9 51.7 52.4 52.8 52.8];



for i = 1:4
AHU6_Load    = AHU6_Load_vec(i)*1000;%btuh      % data is for 1884 mbh = 157 ton adjust
                                                %total load until AHU6 load
                                                %is 157 ton
Cooling_Load_vec(i) = AHU6_Load/0.2/12000;%ton                                  
Load_Capacity=1000;%ton


%% calc eff
Cooling_Load=Cooling_Load_vec(i);
percent_load=Cooling_Load/Load_Capacity;%percent load of chiller

%chiller_eff = sortrows(chiller_eff',1)'


    
for j= 1:length(CHWSTSP_vec(i,:))
    CHWSTSP=CHWSTSP_vec(i,j);
    %[CHWRT__assumeed_vec(i) CHWRT_vec(i)]  = Coil_return_temp(CHWSTSP,AHU6_Load,air_temp-air_temp_setpoint);
    CHWRT_vec(i,j)=CHWRT_ref(i,j);

    dT_water = CHWRT_vec(i,j)-CHWSTSP;
    lift=87-CHWSTSP;
    %%% convert to all 
    kw_chiller_two(i,j)=Cooling_Load*get_eff(percent_load,lift,chiller_eff);
    kw_chiller_final(i,j)=kw_chiller_two(i,j)
    chiller_choice(i,j)=2;
    one_chiller_load = percent_load*2;
    if one_chiller_load > 0.95
        kw_chiller_one(i,j)=0;
    else
        kw_chiller_one(i,j) =Cooling_Load*get_eff(one_chiller_load, lift, chiller_eff);
        if kw_chiller_one(i,j)<kw_chiller_two(i,j)
            kw_chiller_final(i,j)=kw_chiller_one(i,j);
            chiller_choice(i,j)=1;
        end
    end
    
    
    Flow       = AHU6_Load/(CHWRT_vec(i,j)-CHWSTSP)/500;
    Total_Flow= Flow/0.2;
    t_flow(i,j) =Total_Flow;
    Head_Building= 0.00000551724096337*Total_Flow^2+0.00595241445861*Total_Flow+15
    
    t_head (i,j)=Head_Building;
    
    for num= 1:3
    pump_flow = Total_Flow/num;
    [c flow_idx] = min(abs(flow_mat-pump_flow));
    [c head_idx] = min(abs(head_mat-Head_Building));
    if rpm_mat(flow_idx,head_idx) > 1780
        eff_pump(num)=0.00001;
    else
        eff_pump(num)= eff_pump_mat(flow_idx,head_idx);
        t_eff_pump(i,j,num)   = eff_pump(num);
        
    end
    
    end
    i
    j
    [max_eff(i,j) num_pump] = max(eff_pump)
    %Incorprate efficiency in here
    kw_pump(i,j) = 0.7457*Total_Flow*Head_Building/3960/(max_eff(i,j)*0.01);
    pump_choice(i,j)=num_pump
    
    
    
end


%figure(3);plot(CHWRT__assumeed_vec,CHWRT_vec); axis equal
% eff_pump   = get_eff(flow, head,pump_eff)
% 
% cond_T = eva_T+dT_eva;%dT %change this
% %pick a condenser water entering T, compare E with before
% %or after change
% %use designed leaving condensor water T 
% %make a map with lift & percent load chiller
% 
% eff_chiller= get_eff(percent_load*100, cond_T, chiller_eff)
% %use kw/ton map
% %% energy
% e_pump=745.7*n_pump*flow*head/3960/eff_pump%watts 745watt=1hp
% e_chiller=dT_chiller*percent_load*100000/eff_chiller% need actual equation
% %dt  %use kw/ton map
% scatter([0 e_pump], [0 e_chiller])
% xlabel('Energy Pump');
% ylabel('Energy Chiller');
end
total_power=kw_chiller_final+kw_pump;


for i=1:4
    figure(i);
    x0=10;
    y0=10;
    width=1000;
    height=500;
    set(gcf,'units','points','position',[x0,y0,width,height])
    subplot(2,1,2)
    plot(CHWSTSP_vec(i,:),chiller_choice(i,:),CHWSTSP_vec(i,:),pump_choice(i,:))
    for j = 1:length(CHWSTSP_vec(i,:))
        text(CHWSTSP_vec(i,j),3.5, num2str(kw_chiller_one(i,j)));
        text(CHWSTSP_vec(i,j),3.75,num2str(kw_chiller_two(i,j)));
        for num =1:3
        text(CHWSTSP_vec(i,j),0.2*num,num2str(t_eff_pump(i,j,num)))
         end
    end
    legend('num chiller','num pump')
    ylim([0 4])
    subplot(2,1,1)
    plot(CHWSTSP_vec(i,:),kw_chiller_final(i,:),CHWSTSP_vec(i,:),kw_pump(i,:),CHWSTSP_vec(i,:),total_power(i,:));
    
    title([num2str(Cooling_Load_vec(i)) ' ton total Cooling' ])
    for j = 1:length(CHWSTSP_vec(i,:))    
            text(CHWSTSP_vec(i,j)-0.2,50,num2str(t_flow(i,j)))
    end
    ylim([0 500])
    [min_power idx] = min(total_power(i,:));
    t_min_power(i)=min_power;
    t_cwstsp=CHWSTSP_vec(i,idx);
    legend('chiller kw','pump kw', ['min power @ CHWSTSP=' num2str(CHWSTSP_vec(i,idx)) ' for ' num2str(min_power) 'kw'])
end
% ;;title("KW vs CHWST");
% figure(2);plot(CHWSTSP_vec,CHWRT_vec);title("CHWRT vs CHWSTSP");

function eff=get_eff(flow,head,pump_eff)
idx_flow = find(pump_eff(1,:)>flow,1);
flow_hi =pump_eff(1,idx_flow);
flow_low=pump_eff(1,idx_flow-1);

idx_head = find(pump_eff(:,1)>head,1);
head_hi =pump_eff(idx_head,1);
head_low=pump_eff(idx_head-1,1);

percentage_flow = (flow-flow_low)/(flow_hi-flow_low);
percentage_head = (head-head_low)/(head_hi-head_low);

eff_section = pump_eff(idx_head-1:idx_head,idx_flow-1:idx_flow);
low=eff_section(1,1)+percentage_flow*(eff_section(1,2)-eff_section(1,1));
hi =eff_section(2,1)+percentage_flow*(eff_section(2,2)-eff_section(2,1));
eff=low+percentage_head*(hi-low);

end



%system curve
%assume 100 ft max pressure drop, and 2000 gpm
%static pressure of 5 ft to overcome checkvalve pressure


