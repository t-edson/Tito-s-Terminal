MiConfig 0.4.2
==============

## Descriptión

MiConfig is a Lazarus library, which can be used to easily create setting forms or save variables to disk.

With this library, the creation of settings forms is considerably simplified, because the library includes predefined methods that facilitate the manipulation of variables (properties) of the application, so that editing them in a dialog and saving the changes to disk, are done almost transparent.

INI or XML files cam be used.

## A Hello world example

The most basic work to do with MiConfig could be to save variables to disk and recover them.

First of all we need to include the unit MiConfigINI or MiConfigXML, then we need to create an association of the variable with a label (used to identify the variable when it's saved in the output file).

```
uses ..., MiConfigXML;

   ...
   
  //Set some values to variables
  MyText := 'Hello';
  MyNumber := 123;
  //Associate to outputfile
  cfgFile.Asoc_Str('MyText', @MyText, '');  //'MyText' is the label used in disk.
  cfgFile.Asoc_Int('MyNumber', @MyNumber, 0);  //'0' is the default value.
  //Save to disk MyNumber and MyText 
  cfgFile.PropertiesToFile;
  //Read from disk MyNumber and MyText
  cfgFile.FileToProperties;
```

This code will write the value of the variables associated to a file and then will recover the values saved.

Note we are not using controls to editing the content of the variables, we just are associating variables to disk.

## Associating variables to file and to controls

The previous example only associate variables to a file, so they can be read or written in disk. The folw of infromation follows the next figure:

```
 +-----------+                  +-------------+ 
 |           | FileToProperties |             | 
 |           | ---------------> |             | 
 |   Disk    |                  | Variables   | 
 |  (File)   | PropertiesToFile |(Properties) | 
 |           | <--------------- |             | 
 +-----------+                  +-------------+ 
```

This way of working can be used when it is not necessary to edit the properties in controls, because they usually have other means to be modified, such as the width or height of the main window.

However, in many cases we will want to edit properties and save them to disk. In this case we will be following the next flow:

```
 +-----------+                  +-------------+                    +------------+
 |           | FileToProperties |             | PropertiesToWindow |            |
 |           | ---------------> |             | -----------------> |            |
 |   Disk    |                  | Variables   |                    | Controls   |
 |  (File)   | PropertiesToFile |(Properties) | WindowToProperties | (Window)   |
 |           | <--------------- |             | <----------------- |            |
 +-----------+                  +-------------+                    +------------+
```

This is the most common way, when working with forms or settings dialogs, since it is desirable to be able to modify certain properties of the application and keep these changes on disk.

In this case we have two additional methods to control the flow of information to the controls associated:

* PropertiesToWindow 
* WindowToProperties 

They work in a similar way the methods FileToProperties and PropertiesToFile work.

The same methods used to associate variables to disk, can be used to, further, associate this variables to controls too.

For example, if we want to associate "MyVar" variable to a control TEdit, we should write:

```
  cfgFile.Asoc_Str('MyText', @MyText, Edit1, '');
```

Now "Edit1" is the control associated to the variable MyText, then when we execute PropertiesToWindow(), the content of MyText (and all other variables associated) will be moved to Edit1.

In the same way, when executing WindowToProperties(), the value of Edit1, will be assigned to MyText.


### Associating variables to Controls

```
                              +-------------+                    +------------+
                              |             | PropertiesToWindow |            |
                              |             | -----------------> |            |
                              | Variables   |                    | Controles  |
                              |(Properties) | WindowToProperties | (Window)   |
                              |             | <----------------- |            |
                              +-------------+                    +------------+
```

If we don't want to access to disk and just move values from variables to controls, like shown in the previous flow, we can work with a fictitious file and just don't access to disk. 
								

## The output file 

When using the library, it creates a default TMiConfigINI or TMiConfigXML object. It's referenced as "cfgFile" and is the default object used to read or write files from disk.

The name of the file used by "cfgFile" is the same name of the Application, plus the extension ".ini" or ".xml". So if the executable of the project is called "project1.exe", the default file used by "cfgFile" will be "project1.ini" or "project1.xml".

To change the name of this output file, we can use the method SetFileName() of "cfgFile". Logically, this should  be done before of reading (cfgFile.FileToProperties) or writing (cfgFile.PropertiesToFile) data to the file.

## Several output file 

If we want to have more control of the output file, we can create our custom output file. 

The next code assume we want to create a custom output file in XML, called 'my_variables.xml':

```
  myCfgFile := TMiConfigXML.Create('my_variables.xml');  
  
```

Then we can work with "myCfgFile" in the same way we can work with "CfgFile", that is we can associate variables, and read or write to disk.

```
  myCfgFile.Asoc_Str('MyText', @MyText, '');
  myCfgFile.Asoc_Int('MyNumber', @MyNumber, 0);
  ... 
  myCfgFile.PropertiesToFile;
  ...
  myCfgFile.FileToProperties;

```

In this way we can create many output files, each one managing their own variables.


## A simple setting form

With the "MiConfig" library, you can create simple settings forms like this:

```
unit FormConfig;
{$mode objfpc}{$H+}
interface
uses ..., MiConfigINI;  

type
  { TConfig }
  TConfig = class(TForm)
    BitCancel: TBitBtn;
    BitOK: TBitBtn;
    Edit1: TEdit;
    procedure BitOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    //Variables to manage
    MyText : string;
    procedure Initiate(f: TForm);
  end;

var
  Config: TConfig;

implementation
{$R *.lfm}

{ TConfig }
procedure TConfig.FormCreate(Sender: TObject);
begin
  cfgFile.VerifyFile;
end;

procedure TConfig.Initiate(f: TForm);
begin
  //asociate vars to controls
  cfgFile.Asoc_Str('MyText', @MyText, Edit1, '');
  cfgFile.FileToProperties;
end;

procedure TConfig.FormShow(Sender: TObject);
begin
  cfgFile.PropertiesToWindow;
end;

procedure TConfig.BitOKClick(Sender: TObject);
begin
  cfgFile.WindowToProperties;
  self.Close;
end;

procedure TConfig.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  cfgFile.PropertiesToFile;
end;

end.
```

With this code you can edit the value of the "text" variable with the "Edit1" control, and save the changes to disk or read from there.

### Associating variables

The previous examples have shown how to associate only strings and number. However they aren't the only types of variables that can be associated. MiConfig supports several types of variables and several types of controls.

The methods available for creating associations are:

```
    Asoc_Int() --> Associates integers to TEdit, TSpinEdit or TRadioGroup.
    Asoc_Dbl() --> Associates Double to TEdit and TFloatSpinEdit.
    Asoc_Str() --> Associates String to TCustomEdit, TCustomEditButton or TComboBox.
    Asoc_Bol() --> Associates Boolean to TCheckBox or TRadioButton.
    Asoc_Enum() --> Associates Enumerated to TRadioButton or TRadioGroup.
	Asoc_TCol() --> Associates TColor to TColorBox.
	Asoc_StrList_TListBox() --> Associates TStrings to TlistBox
```

These methods are overloaded, to allow association with several controls. For example, it is possible to associate an integer to a TEdit control, but it can also be associated to a TSpinEdit.

Some examples for associations are:

```
  cfgFile.Asoc_Str ('ip'     , @IP   , ComboBox1 , '127.0.0.1');
  cfgFile.Asoc_Bol('Detect' , @detect, chkBoxDetect, false);
  cfgFile.Asoc_Enum('TypDetec'    , @TypDetec  , SizeOf(TypDetec),
         [RadioButton1, RadioButton2, RadioButton3, RadioButton4], 0);
  cfgFile.Asoc_TCol('cbTxtNor' , @colorTxt, colorButTexto, clGray);
  
```

Enumerated types need to pass the size of the variable in the association.

Strings associated can be multilines too.

### Grouping properties

There are two ways to group properties. 

One is setting the field "categ" of the association:

```
  s:=cfgFile.Asoc_TCol('SomeColor', @cTxtNor, cbutTextCol, clBlack);
  s.categ := 1;   //Mark property 
```

Setting different values to field "categ", differente categories of properties are created. Later we can use some selective methods like FileToPropertiesCat() and PropertiesToWindowCat().

Other way (not so formal) to create groups when saving to disk, is to include a prefix in the label for all properties, like in the following code:

```
  cfgFile.Asoc_Bol(section+ '/Autoindent' , @Autoindent , chkBoxAutoind, true);
  cfgFile.Asoc_Bol(section+ '/HighCurLin' , @HighCurLin , chkBoxCurLin , false);
  cfgFile.Asoc_Bol(section+ '/HighCurWord', @HighCurWord, chkBoxCurWord, true);
```

The "section" string is the prefix that defines a group. This method is used when similar groups of variables are used. In this way we can used the same name from the properties, just changing the "section" prefix.


### Creating settings dialogs 

The settings dialogs are usually created in a separated form to separate the code in a ordered way.

This dialog is shown only when it's needed to change some property.

To perform the data movement, the normal thing is to read all the properties when starting the application, then FileToProperties() must be called in the OnCreate event or in the OnShow event (recommended).

It is also common that when the application is terminated, PropertiesToFile() is called to keep the value of the associated variables.
 
All this handling of properties can be done in the main form, but it is advisable to create a special form or configuration dialog, so that it includes the OK and CANCEL buttons. In this case, only when the changes are accepted  WindowToProperties() should be called.

To see the code of an implementation of this type, it is recommended to read the example projects that come in the library.

## Detecting Errors

Commonly, errors can occur when wrong values are placed in controls associated with variables, or when disk is accessed. That is, when one of these methods is executed:


* FileToProperties 
* PropertiesToWindow 
* PropertiesToFile 
* WindowToProperties 

The TMiConfigINI and  TMiConfigXML objects have a string field, called "MsjErr", the purpose of which is to store the error produced in the last operation.

Thus, it is common to use the following code in the OnClick event of the ACCEPT button of the setting form:
```
procedure TConfig.BitOKClick(Sender: TObject);
begin
  iniFile.WindowToProperties;
  if iniFile.MsjErr<>'' then begin
    MsgErr(iniFile.MsjErr);
    exit;
  end;
  self.Close;
end;
```
