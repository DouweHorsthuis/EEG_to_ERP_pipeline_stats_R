function [EEG]= readme_to_EEG(EEG, data_path)
% readme_to_EEG reads a readme file if availible, and adds the data to the EEG
% file, if readme file not availibe questions will be prompted to get the same info
% Usage: [EEG]= readme_to_EEG(EEG, data_path)
% If EEG is [], function still works but will create this file for you
% if data_path is [] or if there is no readme file in that folder 
%     function will instead prompt the questions to the user
% the structuture EEG will have the following added info:
% EEG.notes=Notes from readme file;
% EEG.vision_info=" Left     Right Both (vision scores)";
% EEG.vision=Vision scores from readme file
% EEG.hearing_info=" Frequency Left Right";
% EEG.hz500=Results from readme file
% EEG.hz1000=Results from readme file
% EEG.hz2000=Results from readme file
% EEG.hz4000=Results from readme file
% EEG.age=Results from readme file
% EEG.sex=Results from readme file
% EEG.date=Results from readme file
% EEG.Hand=Results from readme file
% EEG.hearing=Results from readme file
% EEG.vision=Results from readme file
% EEG.glasses=Results from readme file
% EEG.Medication=Results from readme file
% EEG.Exp=Results from readme file
% EEG.Externals=Results from readme file
% EEG.Light=Results from readme file
% EEG.Screen=Results from readme file
% EEG.Cap=Results from readme file
% *note: when "Results from readme file", readme_to_EEG will either find it in the readme file and use it
% or if it doesn't find it, it will promt for the answer.
readme_yn='no';
   notes=[];date_1=[]; Age=[]; Sex=[]; Handedness=[]; glasses=[]; Medication=[]; Exp=[]; Externals=[]; Light=[]; Screen=[];Cap=[]; pres_version=[];
    readme_1=["this is a string to set it up","this is the second string to set it up","this is the 3rd string to set it up","this is the 4rd string to set it up", "this is the last string to set it up"];
 
if ~isempty(data_path)
    data_folder=dir(data_path);
    for i = 1:length(data_folder)
        endsWith(data_folder(i).name,'README.txt');
        readme_yn='yes';
    end
    if strcmpi(readme_yn,'yes')
        for read=1:length(data_folder)
            if endsWith( data_folder(read).name , 'README.txt' )
                readme_1 = fileread([data_path data_folder(read).name]);
            end
        end
        if size(readme_1)==[1,1]
            sprintf('\n \n \n Readme file is loaded wrong, need manual input \n \n \n')
        else
            if contains(readme_1,' Presentation V')
                pres_version=extractBetween(readme_1, '~Run in ', '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            end
            %  for i=1:length(readme_1)
            if contains(readme_1,'Date') && contains(readme_1,'Gender')
                date_1 = extractBetween(readme_1,'Date:', 'Gender');
                date_1 = strtrim(date_1); %deleting tabs, then deleting spaces
                date_1=strcat('Date: ',date_1);
            end
            if contains(readme_1,'Age:') && contains(readme_1,'Hand')
                Age=extractBetween(readme_1, 'Age:', 'Hand');
                Age = strtrim(Age);% deleting tabs, then deleting spaces
                Age=strcat('Age: ',Age);
            end
            if contains(readme_1,'Gender:') && contains(readme_1,'Age:')
                Sex=extractBetween(readme_1, 'Gender:', 'Age:');
                Sex = strtrim(Sex);% deleting tabs, then deleting spaces
                Sex = strcat('Sex: ',Sex);
            end
            if contains(readme_1,'Sex:') && contains(readme_1,'Age:')
                Sex=extractBetween(readme_1, 'Sex:', 'Age:');
                Sex = strtrim(Sex);% deleting tabs, then deleting spaces
                Sex = strcat('Sex: ',Sex);
            end
            if contains(readme_1,'Glasses') && contains(readme_1,'Medic')
                glasses=extractBetween(readme_1, 'contacts:', 'Medic');
                glasses = strtrim(glasses);% deleting tabs, then deleting spaces
                glasses=strcat('Glasses or contacts: ',glasses);
            end
            if contains(readme_1,'Handedness:')  && contains(readme_1,'Tempe')
                Handedness=extractBetween(readme_1, 'Handedness:', 'Tempe');
                Handedness = strtrim(Handedness);% deleting tabs, then deleting spaces
                Handedness=strcat('Handedness: ',Handedness);
            end
            if contains(readme_1,'Medication:')  && contains(readme_1,'Height')
                Medication=extractBetween(readme_1, 'Medication:', 'Height');
                Medication = strtrim(Medication);% deleting tabs, then deleting spaces
                Medication=strcat('Medication: ',Medication);
            end
            if contains(readme_1,'Exp:') && contains(readme_1,'booth')
                Exp=extractBetween(readme_1, 'Exp:', 'booth');
                Exp = strtrim(Exp);% deleting tabs, then deleting spaces
                Exp=strcat('Experimenter: ',Exp);
            end
            if contains(readme_1,'Externals:')&& contains(readme_1,'(normal')
                Externals=extractBetween(readme_1, 'Externals:', '(normal');
                if strlength(Externals)>25
                Externals=extractBetween(readme_1, 'Externals:', 'External location');    
                end
                Externals = strtrim(Externals);% deleting tabs, then deleting spaces
                Externals=strcat('Externals: ',Externals);
            end
            if contains(readme_1,'Light:') && contains(readme_1,'(normal')
                Light=extractBetween(readme_1, 'Light:', '(normal');
                Light = strtrim(Light);% deleting tabs, then deleting spaces
                Light=strcat('Light: ',Light);
            end
            if contains(readme_1,'Screen:') && contains(readme_1,'(')
                Screen=extractBetween(readme_1, 'Screen:', '(');
                Screen = strtrim(Screen);% deleting tabs, then deleting spaces
                Screen=strcat('Screen distance (cm): ',Screen);
            end
            if contains(readme_1,'Cap:') && contains(readme_1,'(color + channels)')
                Cap=extractBetween(readme_1, 'Cap:', '(color + channels)');
                Cap = strtrim(Cap);% deleting tabs, then deleting spaces
                Cap=strcat('Cap size and #channels : ',Cap);
            end
            if contains(readme_1,'notes:') && contains(readme_1,'Save as')
                notes = extractBetween(readme_1,'notes:', 'Save as');
                notes = strtrim(notes); %deleting tabs, then deleting spaces
                notes=strcat('Notes: ',notes);
            end
            
        end
    end
end
if  isempty(pres_version)
    prompt = "What Version of Presentation was used?";
    pres_version= input(prompt,"s"); pres_version=strcat('Presentation Version:',cellstr(pres_version));
end
if  isempty(date_1) || strcmpi(date_1,'Date:') || strlength(date_1)>20
    prompt = "Date of data collection (mm/dd/yyyy): ";
    date_1= input(prompt,"s"); date_1=strcat('Date:',cellstr(date_1));
end
if  isempty(Age) || strcmpi(Age,'Age:') || strlength(Age)>10
    prompt = "Age of participant: ";
    Age= input(prompt,"s"); Age=strcat('Age: ',cellstr(Age));
end
if isempty(Sex) ||strcmpi(Sex,'Sex:') || strlength(Sex)>15
    prompt = "Sex of participant: ";
    Sex= input(prompt,"s"); Sex=strcat('Gender: ', cellstr(Sex));
end
if  isempty(Handedness) || strcmpi(Handedness,'Handedness:') || strlength(Handedness)>25 
    prompt = "Handedness: ";
    Handedness= input(prompt,"s"); Handedness=strcat('Handedness: ',cellstr(Handedness));
end
if isempty(glasses) || strcmpi(glasses,'Glasses or contacts:') || strlength(glasses)>35
    prompt = "glasses or contacts: ";
    glasses= input(prompt,"s"); glasses=strcat('Glasses or contacts: ', cellstr(glasses));
end

if isempty(Medication) || strcmpi(Medication,'Medication:') || strlength(Medication)>40
    prompt = "Medication:";
    Medication= input(prompt,"s");
    if strlength(Medication)>40 %checking if it fits in the figure (+40 chr goes over the edge)
        start=1;med_temp=cellstr(Medication')';med_temp_2={};length_med=ceil(strlength(Medication)/40)*40;
        for i=1:length(med_temp) %to stop the spaces from being deleted
            if isempty(med_temp{i})
                med_temp{i}={' '};
            end
        end
        for ii=40:40:length_med %looks for 80 chr increments
            if start==1
                med_temp_2=[med_temp_2,strcat('Medication: ', strcat(med_temp{start:ii}))];
                
                start=ii+1;
            elseif ii>strlength(Medication)
                med_temp_2=[med_temp_2,strcat(med_temp{start:end})];
            else
                med_temp_2=[med_temp_2,strcat(med_temp{start:ii})];
                start=ii+1;
            end
        end
        Medication=med_temp_2; %Notes are now 80chr but with enters at the end so it still fits
    end
else
   % Medication=['Medication: ',Medication];
end
if isempty(Exp) || strcmpi(Exp,'Exp:') || strlength(Exp)>20
    prompt = "Experimenter: ";
    Exp= input(prompt,"s"); Exp=strcat('Experimenter: ',cellstr(Exp));
end
if isempty(Externals) || strcmpi(Externals,'Externals:') || strlength(Externals)>25
    prompt = "Externals: ";
    Externals= input(prompt,"s"); Externals=strcat('Externals: ',cellstr(Externals));
end
if  isempty(Light)|| strcmpi(Light,'Light:') || strlength(Light)>10
    prompt = "Light on/off: ";
    Light= input(prompt,"s"); Light=strcat('Light: ',cellstr(Light));
end
if  isempty(Screen)|| strcmpi(Screen,'Screen:') || strlength(Screen)>30
    prompt = "Screen distance (cm): ";
    Screen= input(prompt,"s"); Screen=strcat('Screen distance (cm): ',cellstr(Screen));
end
if  isempty(Cap)|| strcmpi(Cap,'Cap:') || strlength(Cap)>50
    prompt = "Cap size and # channels: ";
    Cap= input(prompt,"s"); Cap=strcat('Cap size and #channels : ',cellstr(Cap));
end
%% notes
if  isempty(notes)|| strcmpi(notes,'Notes:') || strlength(notes)>45
    prompt = "Please copy past all the text from the Notes here: ";
    notes= input(prompt,"s");
    if strlength(notes)>45 %checking if it fits in the figure (+90 chr goes over the edge)
        start=1;notes_temp=cellstr(notes')';notes_temp_2={};length_notes=ceil(strlength(notes)/50)*50;
        for i=1:length(notes_temp) %to stop the spaces from being deleted
            if isempty(notes_temp{i})
                notes_temp{i}={' '};
            end
        end
        if ~(rem(45,length_notes)==0)
           length_notes= (ceil(length_notes/45))*45;
        end
        for ii=45:45:length_notes+1 %looks for 80 chr increments
            if start==1
                notes_temp_2=[notes_temp_2,strcat('Notes: ', strcat(notes_temp{start:ii}))];
                start=ii+1;
            elseif ii>strlength(notes) %making sure it will include the last bit
                notes_temp_2=[notes_temp_2,strcat(notes_temp{start:end})];
                break
            else
                notes_temp_2=[notes_temp_2,strcat(notes_temp{start:ii})];
                start=ii+1;
            end
        end
        notes=notes_temp_2; %Notes are now 80chr but with enters at the end so it still fits, if more than 10 lines, it won't fit
    else
        notes=['Notes: ', notes];
    end
end
%% vision and hearing
vision=[];hz500=' 500   Hz:  dB dB ';hz1000=' 1000 Hz:   dB  dB';hz2000=' 2000 Hz:   dB  dB';hz4000=' 4000 Hz:   dB  dB';

if contains(readme_1,'Hearingtest') & contains(readme_1,'500hz') & contains(readme_1,'1000hz') & contains(readme_1,'2000hz') & contains(readme_1,'4000hz')
    hz500=extractBetween(readme_1, '500hz', '1000hz');
    hz500=regexprep(strtrim(hz500), '\t', ' ');% deleting whitespace, tabs, etc
    hz500=strcat('500Hz: ',hz500);
    hz1000=extractBetween(readme_1, '1000hz', '2000hz');
    hz1000=regexprep(strtrim(hz1000), '\t', ' ');% deleting whitespace, tabs, etc
    hz1000=strcat('1000Hz: ',hz1000);
    hz2000=extractBetween(readme_1, '2000hz', '4000hz');
    hz2000=regexprep(strtrim(hz2000), '\t', ' ');% deleting whitespace, tabs, etc
    hz2000=strcat('2000Hz: ',hz2000);
    hz4000=extractBetween(readme_1, '4000hz', 'Vision');
    hz4000=regexprep(strtrim(hz4000), '\t', ' ');% deleting whitespace, tabs, etc
    hz4000=strcat('4000Hz: ',hz4000);
end
if contains(readme_1,'Vision Test:') & contains(readme_1,'notes:')   & contains(readme_1,'vision test is not done on EEG day)') 
    vision=extractBetween(readme_1, 'vision test is not done on EEG day)', 'notes:');
    vision = strtrim(vision);% deleting tabs, then deleting spaces
    vision = regexprep(vision, '\t', ' '); vision = regexprep(vision, '  ', ' '); %cell  {' 20/12 20/32 20/14 '}
    vision=string(vision);
end

if isempty(vision) || contains(readme_1,'20/  20/') || strlength(vision)>20
    prompt = "Vision score left eye: ";
    left_eye= input(prompt,"s");
    prompt = "Vision score right eye: ";
    right_eye= input(prompt,"s");
    prompt = "Vision score both eyes: ";
    both_eye= input(prompt,"s");
    vision=strcat(left_eye, " ",right_eye," ",both_eye);
end 
    if isempty(hz500) || strcmp(string(hz500), " 500   Hz:  dB dB ") || strlength(hz500)>20
        prompt = "500hz hearing test results (left ear/ Right ear): ";
        hz500= input(prompt,"s"); hz500=strcat(' 500   Hz   : ',cellstr(hz500));
    end
    if isempty(hz1000) ||strcmp(string(hz1000), " 1000 Hz:   dB  dB") || strlength(hz1000)>24
        prompt = "1000hz hearing test results (left ear/ Right ear): ";
        hz1000= input(prompt,"s"); hz1000=strcat(' 1000 Hz   : ',cellstr(hz1000));
    end
    if  isempty(hz2000) || strcmp(string(hz2000), " 2000 Hz:   dB  dB") || strlength(hz2000)>24
        prompt = "2000hz hearing test results (left ear/ Right ear): ";
        hz2000= input(prompt,"s"); hz2000=strcat(' 2000 Hz   : ',cellstr(hz2000));
    end
    if isempty(hz4000) || strcmp(string(hz4000), " 4000 Hz:   dB  dB") || strlength(hz4000)>24
        prompt = "4000hz hearing test results (left ear/ Right ear): ";
        hz4000= input(prompt,"s"); hz4000=strcat(' 4000 Hz   : ',cellstr(hz4000));
    end

EEG.notes=notes;
EEG.vision_info=" Left     Right Both (vision scores)";hearing_info= " Frequency Left Right";
EEG.vision=vision; EEG.hearing_info=hearing_info; EEG.hz500=hz500; EEG.hz1000=hz1000; EEG.hz2000=hz2000; EEG.hz4000=hz4000;
EEG.age=Age; EEG.sex=Sex;  EEG.date=date_1; EEG.Hand=Handedness; EEG.hearing=hz1000; EEG.vision=vision;
EEG.glasses=glasses;EEG.Medication=Medication; EEG.Exp=Exp;EEG.Externals=Externals;EEG.Light=Light; EEG.Screen=Screen; EEG.Cap=Cap;
%end