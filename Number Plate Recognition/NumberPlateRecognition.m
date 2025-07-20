function NumberPlateRecognitionGUI()
    % Create the main figure for the GUI
    fig = figure('Name', 'Number Plate Recognition', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1300, 800], 'MenuBar', 'none', ...
                 'Resize', 'off');

    % Add a title label
    uicontrol('Style', 'text', 'Position', [500, 750, 400, 30], ...
              'String', 'Number Plate Recognition System', 'FontSize', 21, ...
              'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % Axes to display images
    ax1 = axes('Parent', fig, 'Position', [0.25, 0.6, 0.2, 0.3]);
    axis(ax1, 'off');
    title(ax1, 'Upload Image 1');

    ax2 = axes('Parent', fig, 'Position', [0.5, 0.6, 0.2, 0.3]);
    axis(ax2, 'off');
    title(ax2, 'Upload Image 2');

    ax3 = axes('Parent', fig, 'Position', [0.75, 0.6, 0.2, 0.3]);
    axis(ax3, 'off');
    title(ax3, 'Upload Image 3');

    % Text labels for contrast values
    contrastText1 = uicontrol('Style', 'text', 'Position', [30, 510, 250, 30], ...
                              'String', 'Contrast of Image 1: ', 'FontSize', 10, ...
                              'HorizontalAlignment', 'left', 'ForegroundColor', 'k');
    contrastText2 = uicontrol('Style', 'text', 'Position', [30, 480, 250, 30], ...
                              'String', 'Contrast of Image 2: ', 'FontSize', 10, ...
                              'HorizontalAlignment', 'left', 'ForegroundColor', 'k');
    contrastText3 = uicontrol('Style', 'text', 'Position', [30, 450, 250, 30], ...
                              'String', 'Contrast of Image 3: ', 'FontSize', 10, ...
                              'HorizontalAlignment', 'left', 'ForegroundColor', 'k');

    % Text label for grayscale conversion weights
   weightsText = uicontrol('Style', 'text', ...
                        'Position', [30, 340, 250, 60], ... % Adjust height for multi-line text
                        'String', {'Grayscale conversion uses optimized weights:', ...
                                   'Red = 0.2989', ...
                                   'Green = 0.5870', ...
                                   'Blue = 0.1140'}, ...
                        'FontSize', 10, ...
                        'HorizontalAlignment', 'left', ...
                        'ForegroundColor', 'k');



    % Axes to display grayscale images
    grayAx1 = axes('Parent', fig, 'Position', [0.25, 0.2, 0.2, 0.3]);
    axis(grayAx1, 'off');
    title(grayAx1, 'Grayscale Image 1');

    grayAx2 = axes('Parent', fig, 'Position', [0.5, 0.2, 0.2, 0.3]);
    axis(grayAx2, 'off');
    title(grayAx2, 'Grayscale Image 2');

    grayAx3 = axes('Parent', fig, 'Position', [0.75, 0.2, 0.2, 0.3]);
    axis(grayAx3, 'off');
    title(grayAx3, 'Grayscale Image 3');

    % Buttons for uploading images and other operations
    buttonY = 700; % Starting Y position of the first button
    buttonHeight = 40; % Height of each button
    buttonGap = 10; % Gap between buttons

    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY, 150, buttonHeight], ...
              'String', 'Upload Image 1', 'FontSize', 10, ...
              'Callback', @(~,~) uploadImage(ax1));
    

    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - (buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Upload Image 2', 'FontSize', 10, ...
              'Callback', @(~,~) uploadImage(ax2));

    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - 2*(buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Upload Image 3', 'FontSize', 10, ...
              'Callback', @(~,~) uploadImage(ax3));

    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - 3*(buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Calculate Contrast', 'FontSize', 10, ...
              'Callback', @(~,~) calculateContrast(ax1, ax2, ax3, contrastText1, contrastText2, contrastText3));

    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - 6*(buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Convert to Grayscale', 'FontSize', 10, ...
              'Callback', @(~,~) convertToGrayscale(ax1, ax2, ax3, grayAx1, grayAx2, grayAx3, weightsText));

    % Button to generate histograms
    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - 8*(buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Show Histograms', 'FontSize', 10, ...
              'Callback', @(~,~) displayHistograms({grayAx1, grayAx2, grayAx3}));

    % Button to isolate number plate
    uicontrol('Style', 'pushbutton', 'Position', [20, buttonY - 9*(buttonHeight + buttonGap), 150, buttonHeight], ...
              'String', 'Isolate Number Plate', 'FontSize', 10, ...
              'Callback', @(~,~) isolateNumberPlate({grayAx1, grayAx2, grayAx3}));
end


% Function to upload and display an image
function uploadImage(ax)
    [fileName, filePath] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'});
    if isequal(fileName, 0)
        return; % User canceled the file selection
    end

    % Load and display the image
    img = imread(fullfile(filePath, fileName));
    imshow(img, 'Parent', ax);
    set(ax, 'UserData', img); % Store the image data in the axes UserData
end


% Function to calculate and display the contrast of the images
function calculateContrast(ax1, ax2, ax3, contrastText1, contrastText2, contrastText3)
    axesList = {ax1, ax2, ax3};
    contrastTexts = {contrastText1, contrastText2, contrastText3};
    for i = 1:3
        ax = axesList{i};
        contrastText = contrastTexts{i};
        img = get(ax, 'UserData');
        if isempty(img)
            set(contrastText, 'String', sprintf('Contrast of Image %d: Not Uploaded', i));
        else
            contrastValue = calculateRMSContrast(img);
            set(contrastText, 'String', sprintf('Contrast of Image %d: %.4f', i, contrastValue));
        end
    end
end


% Function to calculate RMS contrast of an image
function contrast = calculateRMSContrast(img)
    % Convert to grayscale if the image is RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Normalize image to range [0, 1]
    img = double(img) / 255;

    % Compute RMS contrast
    meanIntensity = mean(img(:));
    contrast = sqrt(mean((img(:) - meanIntensity).^2));
end


% Function to convert images to grayscale and display results
function convertToGrayscale(ax1, ax2, ax3, grayAx1, grayAx2, grayAx3, weightsText)
    axesList = {ax1, ax2, ax3};
    grayAxesList = {grayAx1, grayAx2, grayAx3};
    weights = [0.2989, 0.5870, 0.1140]; % Optimized weights for RGB channels
    
    
    
    for i = 1:3
        ax = axesList{i};
        grayAx = grayAxesList{i};
        img = get(ax, 'UserData'); % Retrieve the original image
        if isempty(img)
            msgbox(sprintf('Image %d not uploaded.', i), 'Error', 'error');
        else
            % Convert to grayscale using custom weights
            grayscaleImg = convertToCustomGrayscale(img, weights);

            % Display grayscale image in the respective axes
            imshow(grayscaleImg, 'Parent', grayAx);
            title(grayAx, sprintf('Grayscale Image %d', i));

            % Store the grayscale image in the UserData of the axes
            set(grayAx, 'UserData', grayscaleImg);
        end
    end
end


% Custom function to convert RGB image to grayscale using weights
function grayscaleImg = convertToCustomGrayscale(img, weights)
    if size(img, 3) == 3
        grayscaleImg = weights(1) * img(:, :, 1) + ...
                       weights(2) * img(:, :, 2) + ...
                       weights(3) * img(:, :, 3);
        grayscaleImg = uint8(grayscaleImg);
    else
        grayscaleImg = img; % Image is already grayscale
    end
end


% Function to display histograms of grayscale images in one figure window
function displayHistograms(grayAxes)
    figure('Name', 'Histograms', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);

    for i = 1:length(grayAxes)
        grayAx = grayAxes{i};
        img = get(grayAx, 'UserData'); % Retrieve the grayscale image

        if isempty(img)
            msgbox(sprintf('Grayscale Image %d not available.', i), 'Error', 'error');
        else
            % Ensure the image is grayscale
            if size(img, 3) == 3
                img = rgb2gray(img);
            end

            % Create a subplot for the histogram
            subplot(1, length(grayAxes), i);
            histogram(img(:), 256, 'FaceColor', 'b', 'EdgeColor', 'none');
            title(sprintf('Histogram of Grayscale Image %d', i));
            xlabel('Pixel Intensity');
            ylabel('Frequency');
        end
    end
end


% Function to isolate number plates from images
function isolateNumberPlate(grayAxes)
    % Create a single figure to display results
    figure('Name', 'Number Plate Isolation', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
    
    numImages = length(grayAxes);
    numRows = numImages; % Number of rows equal to the number of images
    numCols = 6; % We need 6 subplots per image

    for i = 1:numImages
        grayAx = grayAxes{i};
        img = get(grayAx, 'UserData'); % Retrieve the grayscale image

        if isempty(img)
            msgbox(sprintf('Grayscale Image %d not available.', i), 'Error', 'error');
        else
            % Pre-Processing
            filteredImg = medfilt2(img, [3, 3]); % Median filtering to remove noise

            % Binarization with Otsu's method
            level = graythresh(filteredImg); % Otsu's thresholding
            binaryImg = imbinarize(filteredImg, level);

            % Morphological operations
            % Use a custom rectangular structuring element for morphological operations
            se = strel('rectangle', [5, 15]); % Structuring element to enhance vertical structures
            morphImg = imopen(binaryImg, se); % Opening to remove small objects
            morphImg = imclose(morphImg, se); % Closing to fill small holes

            % Edge Detection
            edges = edge(morphImg, 'Canny');

            % Identify Regions and Highlight the Number Plate
            props = regionprops(edges, 'BoundingBox', 'Area');
            areas = [props.Area];
            if isempty(areas)
                msgbox(sprintf('No number plate detected in Image %d.', i), 'Error', 'error');
                continue;
            end
            [~, idx] = max(areas); % Assume the largest region corresponds to the number plate
            bbox = props(idx).BoundingBox;

            % Display all results in the same figure for each image
            subplot(numRows, numCols, (i-1)*numCols + 1); imshow(filteredImg); title(sprintf('Filtered Image %d', i));
            subplot(numRows, numCols, (i-1)*numCols + 2); imshow(binaryImg); title(sprintf('Binarized Image %d', i));
            subplot(numRows, numCols, (i-1)*numCols + 3); imshow(morphImg); title(sprintf('Morphologically Processed %d', i));
            subplot(numRows, numCols, (i-1)*numCols + 4); imshow(edges); title(sprintf('Edges %d', i));
            subplot(numRows, numCols, (i-1)*numCols + 5); 
            imshow(img); hold on;
            rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2); % Highlight bounding box
            title(sprintf('Recognized Number Plate %d', i));
            subplot(numRows, numCols, (i-1)*numCols + 6); 
            croppedPlate = imcrop(img, bbox); % Crop the number plate
            imshow(croppedPlate); title(sprintf('Isolated Number Plate %d', i));
        end
    end
end
