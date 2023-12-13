#!/bin/bash

apis=("base" "decidimos" "gobernadores" "miembros" "municipales" "nacionales" "referendo" "seguridad" "silectos")

echo "Las apis a trabajar son: base, decidimos, gobernadores, miembros, municipales, nacionales, referendo, seguridad, silectos"

select api in "${apis[@]}"; 
do
    echo "Selected api: $api"
    cd ./$api
    read -p "Define the model name: " model_name
    model_py="$model_name.py"
    echo "Let's create the model"

    echo "from django.db import models" >> "$model_py"
    echo "class $model_name(models.Model):" >> "$model_py"
    
    while true; do

        read -p "Please enter the atribute name: " atribute
        if [ -z $atribute ]; then
            break
        else
            tipodato=("Integer" "Float" "Char" "Bool" "Date" "DateTime")
            echo "The datatypes are: Integer, Float, Char, Bool, Date and DateTime"
            read -p "Please enter the data type of the atribute: " datatype
            while [[ " ${tipodato[@]} " =~ " ${datatype} " ]] 
            do
               
                if [ $datatype = "Integer" ]; then
                    echo "   " "$atribute = models.IntegerField()" >> "$model_py"
                elif [ $datatype = "Float" ]; then
                    echo "  " "$atribute = models.FloatField()" >> "$model_py"
                elif [ $datatype = "Char" ]; then
                    echo "  " "$atribute = models.CharField()" >> "$model_py"
                elif [ $datatype = "DateTime" ]; then
                    echo "  " "$atribute = models.DateTimeField()" >> "$model_py"
                elif [ $datatype = "Date" ]; then
                    echo "  " "$atribute = models.DateField()" >> "$model_py"
                elif [ $datatype = "Bool" ]; then
                    echo "  " "$atribute = models.BooleanField()" >> "$model_py"
                fi
                break
            done
        fi
    done

    echo "Let's create the view:"
    mkdir views
    cd ./views
    echo "from rest_framework import viewsets" >> "$model_py"
    echo "from base.modelos.$model_name import $model_name" >> "$model_py"
    echo "from base.api.serializers.$model_name import $model_name""Serializers" >> "$model_py"

    echo "class NoticeViewSet(viewsets.ModelViewSet):" >> "$model_py" 
        echo """" >> "$model_py"
        echo "CRUD Notice" >> "$model_py"
        echo """" >> "$model_py"
        echo "queryset = Notice.objects.all()" >> "$model_py"
        echo "serializer_class = NoticeSerializers" >> "$model_py"
    
    echo "Let's create the serializer:"
    cd ..
    mkdir serializers
    cd ./serializers
    echo "from rest_framework import serializers" >> "$model_py"
    echo "from base.modelos.$model_name import $model_name" >> "$model_py"

    echo "class $model_name""Serializers(serializers.ModelSerializer):" >> "$model_py"
    echo "class Meta:" >> "$model_py"
    echo "  "    "model = $model_name" >> "$model_py" 
    echo "  "    "fields = '__all__'" >> "$model_py"
    
    cd ..
    read -p "Defina la ruta: " ruta
    read -p "Defina nombre de la vista: " vista_name
    nueva_linea="    path('$ruta/', generate$ruta.as_view(), name='$vista_name'),"
    temp_file=$(mktemp)
    nueva_linea_insertada=false
    awk -v newline="$nueva_linea" '/path\(/ && !nueva_linea_insertada {print newline; print; nueva_linea_insertada=1} /path\(/ && nueva_linea_insertada {print} !/path\(/ {print}' urls.py > "$temp_file"
    mv "$temp_file" urls.py
    done