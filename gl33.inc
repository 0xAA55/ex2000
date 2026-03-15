%ifndef _GL33_INC_
%define _GL33_INC_ 1

%define GL_DEPTH_BUFFER_BIT               0x00000100
%define GL_STENCIL_BUFFER_BIT             0x00000400
%define GL_COLOR_BUFFER_BIT               0x00004000
%define GL_FALSE                          0
%define GL_TRUE                           1
%define GL_POINTS                         0x0000
%define GL_LINES                          0x0001
%define GL_LINE_LOOP                      0x0002
%define GL_LINE_STRIP                     0x0003
%define GL_TRIANGLES                      0x0004
%define GL_TRIANGLE_STRIP                 0x0005
%define GL_TRIANGLE_FAN                   0x0006
%define GL_QUADS                          0x0007
%define GL_NEVER                          0x0200
%define GL_LESS                           0x0201
%define GL_EQUAL                          0x0202
%define GL_LEQUAL                         0x0203
%define GL_GREATER                        0x0204
%define GL_NOTEQUAL                       0x0205
%define GL_GEQUAL                         0x0206
%define GL_ALWAYS                         0x0207
%define GL_ZERO                           0
%define GL_ONE                            1
%define GL_SRC_COLOR                      0x0300
%define GL_ONE_MINUS_SRC_COLOR            0x0301
%define GL_SRC_ALPHA                      0x0302
%define GL_ONE_MINUS_SRC_ALPHA            0x0303
%define GL_DST_ALPHA                      0x0304
%define GL_ONE_MINUS_DST_ALPHA            0x0305
%define GL_DST_COLOR                      0x0306
%define GL_ONE_MINUS_DST_COLOR            0x0307
%define GL_SRC_ALPHA_SATURATE             0x0308
%define GL_NONE                           0
%define GL_FRONT_LEFT                     0x0400
%define GL_FRONT_RIGHT                    0x0401
%define GL_BACK_LEFT                      0x0402
%define GL_BACK_RIGHT                     0x0403
%define GL_FRONT                          0x0404
%define GL_BACK                           0x0405
%define GL_LEFT                           0x0406
%define GL_RIGHT                          0x0407
%define GL_FRONT_AND_BACK                 0x0408
%define GL_NO_ERROR                       0
%define GL_INVALID_ENUM                   0x0500
%define GL_INVALID_VALUE                  0x0501
%define GL_INVALID_OPERATION              0x0502
%define GL_OUT_OF_MEMORY                  0x0505
%define GL_CW                             0x0900
%define GL_CCW                            0x0901
%define GL_POINT_SIZE                     0x0B11
%define GL_POINT_SIZE_RANGE               0x0B12
%define GL_POINT_SIZE_GRANULARITY         0x0B13
%define GL_LINE_SMOOTH                    0x0B20
%define GL_LINE_WIDTH                     0x0B21
%define GL_LINE_WIDTH_RANGE               0x0B22
%define GL_LINE_WIDTH_GRANULARITY         0x0B23
%define GL_POLYGON_MODE                   0x0B40
%define GL_POLYGON_SMOOTH                 0x0B41
%define GL_CULL_FACE                      0x0B44
%define GL_CULL_FACE_MODE                 0x0B45
%define GL_FRONT_FACE                     0x0B46
%define GL_DEPTH_RANGE                    0x0B70
%define GL_DEPTH_TEST                     0x0B71
%define GL_DEPTH_WRITEMASK                0x0B72
%define GL_DEPTH_CLEAR_VALUE              0x0B73
%define GL_DEPTH_FUNC                     0x0B74
%define GL_STENCIL_TEST                   0x0B90
%define GL_STENCIL_CLEAR_VALUE            0x0B91
%define GL_STENCIL_FUNC                   0x0B92
%define GL_STENCIL_VALUE_MASK             0x0B93
%define GL_STENCIL_FAIL                   0x0B94
%define GL_STENCIL_PASS_DEPTH_FAIL        0x0B95
%define GL_STENCIL_PASS_DEPTH_PASS        0x0B96
%define GL_STENCIL_REF                    0x0B97
%define GL_STENCIL_WRITEMASK              0x0B98
%define GL_VIEWPORT                       0x0BA2
%define GL_DITHER                         0x0BD0
%define GL_BLEND_DST                      0x0BE0
%define GL_BLEND_SRC                      0x0BE1
%define GL_BLEND                          0x0BE2
%define GL_LOGIC_OP_MODE                  0x0BF0
%define GL_DRAW_BUFFER                    0x0C01
%define GL_READ_BUFFER                    0x0C02
%define GL_SCISSOR_BOX                    0x0C10
%define GL_SCISSOR_TEST                   0x0C11
%define GL_COLOR_CLEAR_VALUE              0x0C22
%define GL_COLOR_WRITEMASK                0x0C23
%define GL_DOUBLEBUFFER                   0x0C32
%define GL_STEREO                         0x0C33
%define GL_LINE_SMOOTH_HINT               0x0C52
%define GL_POLYGON_SMOOTH_HINT            0x0C53
%define GL_UNPACK_SWAP_BYTES              0x0CF0
%define GL_UNPACK_LSB_FIRST               0x0CF1
%define GL_UNPACK_ROW_LENGTH              0x0CF2
%define GL_UNPACK_SKIP_ROWS               0x0CF3
%define GL_UNPACK_SKIP_PIXELS             0x0CF4
%define GL_UNPACK_ALIGNMENT               0x0CF5
%define GL_PACK_SWAP_BYTES                0x0D00
%define GL_PACK_LSB_FIRST                 0x0D01
%define GL_PACK_ROW_LENGTH                0x0D02
%define GL_PACK_SKIP_ROWS                 0x0D03
%define GL_PACK_SKIP_PIXELS               0x0D04
%define GL_PACK_ALIGNMENT                 0x0D05
%define GL_MAX_TEXTURE_SIZE               0x0D33
%define GL_MAX_VIEWPORT_DIMS              0x0D3A
%define GL_SUBPIXEL_BITS                  0x0D50
%define GL_TEXTURE_1D                     0x0DE0
%define GL_TEXTURE_2D                     0x0DE1
%define GL_TEXTURE_WIDTH                  0x1000
%define GL_TEXTURE_HEIGHT                 0x1001
%define GL_TEXTURE_BORDER_COLOR           0x1004
%define GL_DONT_CARE                      0x1100
%define GL_FASTEST                        0x1101
%define GL_NICEST                         0x1102
%define GL_BYTE                           0x1400
%define GL_UNSIGNED_BYTE                  0x1401
%define GL_SHORT                          0x1402
%define GL_UNSIGNED_SHORT                 0x1403
%define GL_INT                            0x1404
%define GL_UNSIGNED_INT                   0x1405
%define GL_FLOAT                          0x1406
%define GL_STACK_OVERFLOW                 0x0503
%define GL_STACK_UNDERFLOW                0x0504
%define GL_CLEAR                          0x1500
%define GL_AND                            0x1501
%define GL_AND_REVERSE                    0x1502
%define GL_COPY                           0x1503
%define GL_AND_INVERTED                   0x1504
%define GL_NOOP                           0x1505
%define GL_XOR                            0x1506
%define GL_OR                             0x1507
%define GL_NOR                            0x1508
%define GL_EQUIV                          0x1509
%define GL_INVERT                         0x150A
%define GL_OR_REVERSE                     0x150B
%define GL_COPY_INVERTED                  0x150C
%define GL_OR_INVERTED                    0x150D
%define GL_NAND                           0x150E
%define GL_SET                            0x150F
%define GL_TEXTURE                        0x1702
%define GL_COLOR                          0x1800
%define GL_DEPTH                          0x1801
%define GL_STENCIL                        0x1802
%define GL_STENCIL_INDEX                  0x1901
%define GL_DEPTH_COMPONENT                0x1902
%define GL_RED                            0x1903
%define GL_GREEN                          0x1904
%define GL_BLUE                           0x1905
%define GL_ALPHA                          0x1906
%define GL_RGB                            0x1907
%define GL_RGBA                           0x1908
%define GL_POINT                          0x1B00
%define GL_LINE                           0x1B01
%define GL_FILL                           0x1B02
%define GL_KEEP                           0x1E00
%define GL_REPLACE                        0x1E01
%define GL_INCR                           0x1E02
%define GL_DECR                           0x1E03
%define GL_VENDOR                         0x1F00
%define GL_RENDERER                       0x1F01
%define GL_VERSION                        0x1F02
%define GL_EXTENSIONS                     0x1F03
%define GL_NEAREST                        0x2600
%define GL_LINEAR                         0x2601
%define GL_NEAREST_MIPMAP_NEAREST         0x2700
%define GL_LINEAR_MIPMAP_NEAREST          0x2701
%define GL_NEAREST_MIPMAP_LINEAR          0x2702
%define GL_LINEAR_MIPMAP_LINEAR           0x2703
%define GL_TEXTURE_MAG_FILTER             0x2800
%define GL_TEXTURE_MIN_FILTER             0x2801
%define GL_TEXTURE_WRAP_S                 0x2802
%define GL_TEXTURE_WRAP_T                 0x2803
%define GL_REPEAT                         0x2901
%define GL_COLOR_LOGIC_OP                 0x0BF2
%define GL_POLYGON_OFFSET_UNITS           0x2A00
%define GL_POLYGON_OFFSET_POINT           0x2A01
%define GL_POLYGON_OFFSET_LINE            0x2A02
%define GL_POLYGON_OFFSET_FILL            0x8037
%define GL_POLYGON_OFFSET_FACTOR          0x8038
%define GL_TEXTURE_BINDING_1D             0x8068
%define GL_TEXTURE_BINDING_2D             0x8069
%define GL_TEXTURE_INTERNAL_FORMAT        0x1003
%define GL_TEXTURE_RED_SIZE               0x805C
%define GL_TEXTURE_GREEN_SIZE             0x805D
%define GL_TEXTURE_BLUE_SIZE              0x805E
%define GL_TEXTURE_ALPHA_SIZE             0x805F
%define GL_DOUBLE                         0x140A
%define GL_PROXY_TEXTURE_1D               0x8063
%define GL_PROXY_TEXTURE_2D               0x8064
%define GL_R3_G3_B2                       0x2A10
%define GL_RGB4                           0x804F
%define GL_RGB5                           0x8050
%define GL_RGB8                           0x8051
%define GL_RGB10                          0x8052
%define GL_RGB12                          0x8053
%define GL_RGB16                          0x8054
%define GL_RGBA2                          0x8055
%define GL_RGBA4                          0x8056
%define GL_RGB5_A1                        0x8057
%define GL_RGBA8                          0x8058
%define GL_RGB10_A2                       0x8059
%define GL_RGBA12                         0x805A
%define GL_RGBA16                         0x805B
%define GL_VERTEX_ARRAY                   0x8074
%define GL_UNSIGNED_BYTE_3_3_2            0x8032
%define GL_UNSIGNED_SHORT_4_4_4_4         0x8033
%define GL_UNSIGNED_SHORT_5_5_5_1         0x8034
%define GL_UNSIGNED_INT_8_8_8_8           0x8035
%define GL_UNSIGNED_INT_10_10_10_2        0x8036
%define GL_TEXTURE_BINDING_3D             0x806A
%define GL_PACK_SKIP_IMAGES               0x806B
%define GL_PACK_IMAGE_HEIGHT              0x806C
%define GL_UNPACK_SKIP_IMAGES             0x806D
%define GL_UNPACK_IMAGE_HEIGHT            0x806E
%define GL_TEXTURE_3D                     0x806F
%define GL_PROXY_TEXTURE_3D               0x8070
%define GL_TEXTURE_DEPTH                  0x8071
%define GL_TEXTURE_WRAP_R                 0x8072
%define GL_MAX_3D_TEXTURE_SIZE            0x8073
%define GL_UNSIGNED_BYTE_2_3_3_REV        0x8362
%define GL_UNSIGNED_SHORT_5_6_5           0x8363
%define GL_UNSIGNED_SHORT_5_6_5_REV       0x8364
%define GL_UNSIGNED_SHORT_4_4_4_4_REV     0x8365
%define GL_UNSIGNED_SHORT_1_5_5_5_REV     0x8366
%define GL_UNSIGNED_INT_8_8_8_8_REV       0x8367
%define GL_UNSIGNED_INT_2_10_10_10_REV    0x8368
%define GL_BGR                            0x80E0
%define GL_BGRA                           0x80E1
%define GL_MAX_ELEMENTS_VERTICES          0x80E8
%define GL_MAX_ELEMENTS_INDICES           0x80E9
%define GL_CLAMP_TO_EDGE                  0x812F
%define GL_TEXTURE_MIN_LOD                0x813A
%define GL_TEXTURE_MAX_LOD                0x813B
%define GL_TEXTURE_BASE_LEVEL             0x813C
%define GL_TEXTURE_MAX_LEVEL              0x813D
%define GL_SMOOTH_POINT_SIZE_RANGE        0x0B12
%define GL_SMOOTH_POINT_SIZE_GRANULARITY  0x0B13
%define GL_SMOOTH_LINE_WIDTH_RANGE        0x0B22
%define GL_SMOOTH_LINE_WIDTH_GRANULARITY  0x0B23
%define GL_ALIASED_LINE_WIDTH_RANGE       0x846E
%define GL_RESCALE_NORMAL                 0x803A
%define GL_LIGHT_MODEL_COLOR_CONTROL      0x81F8
%define GL_SINGLE_COLOR                   0x81F9
%define GL_SEPARATE_SPECULAR_COLOR        0x81FA
%define GL_ALIASED_POINT_SIZE_RANGE       0x846D
%define GL_TEXTURE0                       0x84C0
%define GL_TEXTURE1                       0x84C1
%define GL_TEXTURE2                       0x84C2
%define GL_TEXTURE3                       0x84C3
%define GL_TEXTURE4                       0x84C4
%define GL_TEXTURE5                       0x84C5
%define GL_TEXTURE6                       0x84C6
%define GL_TEXTURE7                       0x84C7
%define GL_TEXTURE8                       0x84C8
%define GL_TEXTURE9                       0x84C9
%define GL_TEXTURE10                      0x84CA
%define GL_TEXTURE11                      0x84CB
%define GL_TEXTURE12                      0x84CC
%define GL_TEXTURE13                      0x84CD
%define GL_TEXTURE14                      0x84CE
%define GL_TEXTURE15                      0x84CF
%define GL_TEXTURE16                      0x84D0
%define GL_TEXTURE17                      0x84D1
%define GL_TEXTURE18                      0x84D2
%define GL_TEXTURE19                      0x84D3
%define GL_TEXTURE20                      0x84D4
%define GL_TEXTURE21                      0x84D5
%define GL_TEXTURE22                      0x84D6
%define GL_TEXTURE23                      0x84D7
%define GL_TEXTURE24                      0x84D8
%define GL_TEXTURE25                      0x84D9
%define GL_TEXTURE26                      0x84DA
%define GL_TEXTURE27                      0x84DB
%define GL_TEXTURE28                      0x84DC
%define GL_TEXTURE29                      0x84DD
%define GL_TEXTURE30                      0x84DE
%define GL_TEXTURE31                      0x84DF
%define GL_ACTIVE_TEXTURE                 0x84E0
%define GL_MULTISAMPLE                    0x809D
%define GL_SAMPLE_ALPHA_TO_COVERAGE       0x809E
%define GL_SAMPLE_ALPHA_TO_ONE            0x809F
%define GL_SAMPLE_COVERAGE                0x80A0
%define GL_SAMPLE_BUFFERS                 0x80A8
%define GL_SAMPLES                        0x80A9
%define GL_SAMPLE_COVERAGE_VALUE          0x80AA
%define GL_SAMPLE_COVERAGE_INVERT         0x80AB
%define GL_TEXTURE_CUBE_MAP               0x8513
%define GL_TEXTURE_BINDING_CUBE_MAP       0x8514
%define GL_TEXTURE_CUBE_MAP_POSITIVE_X    0x8515
%define GL_TEXTURE_CUBE_MAP_NEGATIVE_X    0x8516
%define GL_TEXTURE_CUBE_MAP_POSITIVE_Y    0x8517
%define GL_TEXTURE_CUBE_MAP_NEGATIVE_Y    0x8518
%define GL_TEXTURE_CUBE_MAP_POSITIVE_Z    0x8519
%define GL_TEXTURE_CUBE_MAP_NEGATIVE_Z    0x851A
%define GL_PROXY_TEXTURE_CUBE_MAP         0x851B
%define GL_MAX_CUBE_MAP_TEXTURE_SIZE      0x851C
%define GL_COMPRESSED_RGB                 0x84ED
%define GL_COMPRESSED_RGBA                0x84EE
%define GL_TEXTURE_COMPRESSION_HINT       0x84EF
%define GL_TEXTURE_COMPRESSED_IMAGE_SIZE  0x86A0
%define GL_TEXTURE_COMPRESSED             0x86A1
%define GL_NUM_COMPRESSED_TEXTURE_FORMATS 0x86A2
%define GL_COMPRESSED_TEXTURE_FORMATS     0x86A3
%define GL_CLAMP_TO_BORDER                0x812D
%define GL_CLIENT_ACTIVE_TEXTURE          0x84E1
%define GL_MAX_TEXTURE_UNITS              0x84E2
%define GL_TRANSPOSE_MODELVIEW_MATRIX     0x84E3
%define GL_TRANSPOSE_PROJECTION_MATRIX    0x84E4
%define GL_TRANSPOSE_TEXTURE_MATRIX       0x84E5
%define GL_TRANSPOSE_COLOR_MATRIX         0x84E6
%define GL_MULTISAMPLE_BIT                0x20000000
%define GL_NORMAL_MAP                     0x8511
%define GL_REFLECTION_MAP                 0x8512
%define GL_COMPRESSED_ALPHA               0x84E9
%define GL_COMPRESSED_LUMINANCE           0x84EA
%define GL_COMPRESSED_LUMINANCE_ALPHA     0x84EB
%define GL_COMPRESSED_INTENSITY           0x84EC
%define GL_COMBINE                        0x8570
%define GL_COMBINE_RGB                    0x8571
%define GL_COMBINE_ALPHA                  0x8572
%define GL_SOURCE0_RGB                    0x8580
%define GL_SOURCE1_RGB                    0x8581
%define GL_SOURCE2_RGB                    0x8582
%define GL_SOURCE0_ALPHA                  0x8588
%define GL_SOURCE1_ALPHA                  0x8589
%define GL_SOURCE2_ALPHA                  0x858A
%define GL_OPERAND0_RGB                   0x8590
%define GL_OPERAND1_RGB                   0x8591
%define GL_OPERAND2_RGB                   0x8592
%define GL_OPERAND0_ALPHA                 0x8598
%define GL_OPERAND1_ALPHA                 0x8599
%define GL_OPERAND2_ALPHA                 0x859A
%define GL_RGB_SCALE                      0x8573
%define GL_ADD_SIGNED                     0x8574
%define GL_INTERPOLATE                    0x8575
%define GL_SUBTRACT                       0x84E7
%define GL_CONSTANT                       0x8576
%define GL_PRIMARY_COLOR                  0x8577
%define GL_PREVIOUS                       0x8578
%define GL_DOT3_RGB                       0x86AE
%define GL_DOT3_RGBA                      0x86AF
%define GL_BLEND_DST_RGB                  0x80C8
%define GL_BLEND_SRC_RGB                  0x80C9
%define GL_BLEND_DST_ALPHA                0x80CA
%define GL_BLEND_SRC_ALPHA                0x80CB
%define GL_POINT_FADE_THRESHOLD_SIZE      0x8128
%define GL_DEPTH_COMPONENT16              0x81A5
%define GL_DEPTH_COMPONENT24              0x81A6
%define GL_DEPTH_COMPONENT32              0x81A7
%define GL_MIRRORED_REPEAT                0x8370
%define GL_MAX_TEXTURE_LOD_BIAS           0x84FD
%define GL_TEXTURE_LOD_BIAS               0x8501
%define GL_INCR_WRAP                      0x8507
%define GL_DECR_WRAP                      0x8508
%define GL_TEXTURE_DEPTH_SIZE             0x884A
%define GL_TEXTURE_COMPARE_MODE           0x884C
%define GL_TEXTURE_COMPARE_FUNC           0x884D
%define GL_POINT_SIZE_MIN                 0x8126
%define GL_POINT_SIZE_MAX                 0x8127
%define GL_POINT_DISTANCE_ATTENUATION     0x8129
%define GL_GENERATE_MIPMAP                0x8191
%define GL_GENERATE_MIPMAP_HINT           0x8192
%define GL_FOG_COORDINATE_SOURCE          0x8450
%define GL_FOG_COORDINATE                 0x8451
%define GL_FRAGMENT_DEPTH                 0x8452
%define GL_CURRENT_FOG_COORDINATE         0x8453
%define GL_FOG_COORDINATE_ARRAY_TYPE      0x8454
%define GL_FOG_COORDINATE_ARRAY_STRIDE    0x8455
%define GL_FOG_COORDINATE_ARRAY_POINTER   0x8456
%define GL_FOG_COORDINATE_ARRAY           0x8457
%define GL_COLOR_SUM                      0x8458
%define GL_CURRENT_SECONDARY_COLOR        0x8459
%define GL_SECONDARY_COLOR_ARRAY_SIZE     0x845A
%define GL_SECONDARY_COLOR_ARRAY_TYPE     0x845B
%define GL_SECONDARY_COLOR_ARRAY_STRIDE   0x845C
%define GL_SECONDARY_COLOR_ARRAY_POINTER  0x845D
%define GL_SECONDARY_COLOR_ARRAY          0x845E
%define GL_TEXTURE_FILTER_CONTROL         0x8500
%define GL_DEPTH_TEXTURE_MODE             0x884B
%define GL_COMPARE_R_TO_TEXTURE           0x884E
%define GL_BLEND_COLOR                    0x8005
%define GL_BLEND_EQUATION                 0x8009
%define GL_CONSTANT_COLOR                 0x8001
%define GL_ONE_MINUS_CONSTANT_COLOR       0x8002
%define GL_CONSTANT_ALPHA                 0x8003
%define GL_ONE_MINUS_CONSTANT_ALPHA       0x8004
%define GL_FUNC_ADD                       0x8006
%define GL_FUNC_REVERSE_SUBTRACT          0x800B
%define GL_FUNC_SUBTRACT                  0x800A
%define GL_MIN                            0x8007
%define GL_MAX                            0x8008

%define GL_BUFFER_SIZE                    0x8764
%define GL_BUFFER_USAGE                   0x8765
%define GL_QUERY_COUNTER_BITS             0x8864
%define GL_CURRENT_QUERY                  0x8865
%define GL_QUERY_RESULT                   0x8866
%define GL_QUERY_RESULT_AVAILABLE         0x8867
%define GL_ARRAY_BUFFER                   0x8892
%define GL_ELEMENT_ARRAY_BUFFER           0x8893
%define GL_ARRAY_BUFFER_BINDING           0x8894
%define GL_ELEMENT_ARRAY_BUFFER_BINDING   0x8895
%define GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING 0x889F
%define GL_READ_ONLY                      0x88B8
%define GL_WRITE_ONLY                     0x88B9
%define GL_READ_WRITE                     0x88BA
%define GL_BUFFER_ACCESS                  0x88BB
%define GL_BUFFER_MAPPED                  0x88BC
%define GL_BUFFER_MAP_POINTER             0x88BD
%define GL_STREAM_DRAW                    0x88E0
%define GL_STREAM_READ                    0x88E1
%define GL_STREAM_COPY                    0x88E2
%define GL_STATIC_DRAW                    0x88E4
%define GL_STATIC_READ                    0x88E5
%define GL_STATIC_COPY                    0x88E6
%define GL_DYNAMIC_DRAW                   0x88E8
%define GL_DYNAMIC_READ                   0x88E9
%define GL_DYNAMIC_COPY                   0x88EA
%define GL_SAMPLES_PASSED                 0x8914
%define GL_SRC1_ALPHA                     0x8589
%define GL_VERTEX_ARRAY_BUFFER_BINDING    0x8896
%define GL_NORMAL_ARRAY_BUFFER_BINDING    0x8897
%define GL_COLOR_ARRAY_BUFFER_BINDING     0x8898
%define GL_INDEX_ARRAY_BUFFER_BINDING     0x8899
%define GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING 0x889A
%define GL_EDGE_FLAG_ARRAY_BUFFER_BINDING 0x889B
%define GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING 0x889C
%define GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING 0x889D
%define GL_WEIGHT_ARRAY_BUFFER_BINDING    0x889E
%define GL_FOG_COORD_SRC                  0x8450
%define GL_FOG_COORD                      0x8451
%define GL_CURRENT_FOG_COORD              0x8453
%define GL_FOG_COORD_ARRAY_TYPE           0x8454
%define GL_FOG_COORD_ARRAY_STRIDE         0x8455
%define GL_FOG_COORD_ARRAY_POINTER        0x8456
%define GL_FOG_COORD_ARRAY                0x8457
%define GL_FOG_COORD_ARRAY_BUFFER_BINDING 0x889D
%define GL_SRC0_RGB                       0x8580
%define GL_SRC1_RGB                       0x8581
%define GL_SRC2_RGB                       0x8582
%define GL_SRC0_ALPHA                     0x8588
%define GL_SRC2_ALPHA                     0x858A

%define GL_BLEND_EQUATION_RGB             0x8009
%define GL_VERTEX_ATTRIB_ARRAY_ENABLED    0x8622
%define GL_VERTEX_ATTRIB_ARRAY_SIZE       0x8623
%define GL_VERTEX_ATTRIB_ARRAY_STRIDE     0x8624
%define GL_VERTEX_ATTRIB_ARRAY_TYPE       0x8625
%define GL_CURRENT_VERTEX_ATTRIB          0x8626
%define GL_VERTEX_PROGRAM_POINT_SIZE      0x8642
%define GL_VERTEX_ATTRIB_ARRAY_POINTER    0x8645
%define GL_STENCIL_BACK_FUNC              0x8800
%define GL_STENCIL_BACK_FAIL              0x8801
%define GL_STENCIL_BACK_PASS_DEPTH_FAIL   0x8802
%define GL_STENCIL_BACK_PASS_DEPTH_PASS   0x8803
%define GL_MAX_DRAW_BUFFERS               0x8824
%define GL_DRAW_BUFFER0                   0x8825
%define GL_DRAW_BUFFER1                   0x8826
%define GL_DRAW_BUFFER2                   0x8827
%define GL_DRAW_BUFFER3                   0x8828
%define GL_DRAW_BUFFER4                   0x8829
%define GL_DRAW_BUFFER5                   0x882A
%define GL_DRAW_BUFFER6                   0x882B
%define GL_DRAW_BUFFER7                   0x882C
%define GL_DRAW_BUFFER8                   0x882D
%define GL_DRAW_BUFFER9                   0x882E
%define GL_DRAW_BUFFER10                  0x882F
%define GL_DRAW_BUFFER11                  0x8830
%define GL_DRAW_BUFFER12                  0x8831
%define GL_DRAW_BUFFER13                  0x8832
%define GL_DRAW_BUFFER14                  0x8833
%define GL_DRAW_BUFFER15                  0x8834
%define GL_BLEND_EQUATION_ALPHA           0x883D
%define GL_MAX_VERTEX_ATTRIBS             0x8869
%define GL_VERTEX_ATTRIB_ARRAY_NORMALIZED 0x886A
%define GL_MAX_TEXTURE_IMAGE_UNITS        0x8872
%define GL_FRAGMENT_SHADER                0x8B30
%define GL_VERTEX_SHADER                  0x8B31
%define GL_MAX_FRAGMENT_UNIFORM_COMPONENTS 0x8B49
%define GL_MAX_VERTEX_UNIFORM_COMPONENTS  0x8B4A
%define GL_MAX_VARYING_FLOATS             0x8B4B
%define GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS 0x8B4C
%define GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS 0x8B4D
%define GL_SHADER_TYPE                    0x8B4F
%define GL_FLOAT_VEC2                     0x8B50
%define GL_FLOAT_VEC3                     0x8B51
%define GL_FLOAT_VEC4                     0x8B52
%define GL_INT_VEC2                       0x8B53
%define GL_INT_VEC3                       0x8B54
%define GL_INT_VEC4                       0x8B55
%define GL_BOOL                           0x8B56
%define GL_BOOL_VEC2                      0x8B57
%define GL_BOOL_VEC3                      0x8B58
%define GL_BOOL_VEC4                      0x8B59
%define GL_FLOAT_MAT2                     0x8B5A
%define GL_FLOAT_MAT3                     0x8B5B
%define GL_FLOAT_MAT4                     0x8B5C
%define GL_SAMPLER_1D                     0x8B5D
%define GL_SAMPLER_2D                     0x8B5E
%define GL_SAMPLER_3D                     0x8B5F
%define GL_SAMPLER_CUBE                   0x8B60
%define GL_SAMPLER_1D_SHADOW              0x8B61
%define GL_SAMPLER_2D_SHADOW              0x8B62
%define GL_DELETE_STATUS                  0x8B80
%define GL_COMPILE_STATUS                 0x8B81
%define GL_LINK_STATUS                    0x8B82
%define GL_VALIDATE_STATUS                0x8B83
%define GL_INFO_LOG_LENGTH                0x8B84
%define GL_ATTACHED_SHADERS               0x8B85
%define GL_ACTIVE_UNIFORMS                0x8B86
%define GL_ACTIVE_UNIFORM_MAX_LENGTH      0x8B87
%define GL_SHADER_SOURCE_LENGTH           0x8B88
%define GL_ACTIVE_ATTRIBUTES              0x8B89
%define GL_ACTIVE_ATTRIBUTE_MAX_LENGTH    0x8B8A
%define GL_FRAGMENT_SHADER_DERIVATIVE_HINT 0x8B8B
%define GL_SHADING_LANGUAGE_VERSION       0x8B8C
%define GL_CURRENT_PROGRAM                0x8B8D
%define GL_POINT_SPRITE_COORD_ORIGIN      0x8CA0
%define GL_LOWER_LEFT                     0x8CA1
%define GL_UPPER_LEFT                     0x8CA2
%define GL_STENCIL_BACK_REF               0x8CA3
%define GL_STENCIL_BACK_VALUE_MASK        0x8CA4
%define GL_STENCIL_BACK_WRITEMASK         0x8CA5
%define GL_VERTEX_PROGRAM_TWO_SIDE        0x8643
%define GL_POINT_SPRITE                   0x8861
%define GL_COORD_REPLACE                  0x8862
%define GL_MAX_TEXTURE_COORDS             0x8871

%define GL_PIXEL_PACK_BUFFER              0x88EB
%define GL_PIXEL_UNPACK_BUFFER            0x88EC
%define GL_PIXEL_PACK_BUFFER_BINDING      0x88ED
%define GL_PIXEL_UNPACK_BUFFER_BINDING    0x88EF
%define GL_FLOAT_MAT2x3                   0x8B65
%define GL_FLOAT_MAT2x4                   0x8B66
%define GL_FLOAT_MAT3x2                   0x8B67
%define GL_FLOAT_MAT3x4                   0x8B68
%define GL_FLOAT_MAT4x2                   0x8B69
%define GL_FLOAT_MAT4x3                   0x8B6A
%define GL_SRGB                           0x8C40
%define GL_SRGB8                          0x8C41
%define GL_SRGB_ALPHA                     0x8C42
%define GL_SRGB8_ALPHA8                   0x8C43
%define GL_COMPRESSED_SRGB                0x8C48
%define GL_COMPRESSED_SRGB_ALPHA          0x8C49
%define GL_CURRENT_RASTER_SECONDARY_COLOR 0x845F
%define GL_SLUMINANCE_ALPHA               0x8C44
%define GL_SLUMINANCE8_ALPHA8             0x8C45
%define GL_SLUMINANCE                     0x8C46
%define GL_SLUMINANCE8                    0x8C47
%define GL_COMPRESSED_SLUMINANCE          0x8C4A
%define GL_COMPRESSED_SLUMINANCE_ALPHA    0x8C4B

%define GL_COMPARE_REF_TO_TEXTURE         0x884E
%define GL_CLIP_DISTANCE0                 0x3000
%define GL_CLIP_DISTANCE1                 0x3001
%define GL_CLIP_DISTANCE2                 0x3002
%define GL_CLIP_DISTANCE3                 0x3003
%define GL_CLIP_DISTANCE4                 0x3004
%define GL_CLIP_DISTANCE5                 0x3005
%define GL_CLIP_DISTANCE6                 0x3006
%define GL_CLIP_DISTANCE7                 0x3007
%define GL_MAX_CLIP_DISTANCES             0x0D32
%define GL_MAJOR_VERSION                  0x821B
%define GL_MINOR_VERSION                  0x821C
%define GL_NUM_EXTENSIONS                 0x821D
%define GL_CONTEXT_FLAGS                  0x821E
%define GL_COMPRESSED_RED                 0x8225
%define GL_COMPRESSED_RG                  0x8226
%define GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT 0x00000001
%define GL_RGBA32F                        0x8814
%define GL_RGB32F                         0x8815
%define GL_RGBA16F                        0x881A
%define GL_RGB16F                         0x881B
%define GL_VERTEX_ATTRIB_ARRAY_INTEGER    0x88FD
%define GL_MAX_ARRAY_TEXTURE_LAYERS       0x88FF
%define GL_MIN_PROGRAM_TEXEL_OFFSET       0x8904
%define GL_MAX_PROGRAM_TEXEL_OFFSET       0x8905
%define GL_CLAMP_READ_COLOR               0x891C
%define GL_FIXED_ONLY                     0x891D
%define GL_MAX_VARYING_COMPONENTS         0x8B4B
%define GL_TEXTURE_1D_ARRAY               0x8C18
%define GL_PROXY_TEXTURE_1D_ARRAY         0x8C19
%define GL_TEXTURE_2D_ARRAY               0x8C1A
%define GL_PROXY_TEXTURE_2D_ARRAY         0x8C1B
%define GL_TEXTURE_BINDING_1D_ARRAY       0x8C1C
%define GL_TEXTURE_BINDING_2D_ARRAY       0x8C1D
%define GL_R11F_G11F_B10F                 0x8C3A
%define GL_UNSIGNED_INT_10F_11F_11F_REV   0x8C3B
%define GL_RGB9_E5                        0x8C3D
%define GL_UNSIGNED_INT_5_9_9_9_REV       0x8C3E
%define GL_TEXTURE_SHARED_SIZE            0x8C3F
%define GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH 0x8C76
%define GL_TRANSFORM_FEEDBACK_BUFFER_MODE 0x8C7F
%define GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS 0x8C80
%define GL_TRANSFORM_FEEDBACK_VARYINGS    0x8C83
%define GL_TRANSFORM_FEEDBACK_BUFFER_START 0x8C84
%define GL_TRANSFORM_FEEDBACK_BUFFER_SIZE 0x8C85
%define GL_PRIMITIVES_GENERATED           0x8C87
%define GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN 0x8C88
%define GL_RASTERIZER_DISCARD             0x8C89
%define GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS 0x8C8A
%define GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS 0x8C8B
%define GL_INTERLEAVED_ATTRIBS            0x8C8C
%define GL_SEPARATE_ATTRIBS               0x8C8D
%define GL_TRANSFORM_FEEDBACK_BUFFER      0x8C8E
%define GL_TRANSFORM_FEEDBACK_BUFFER_BINDING 0x8C8F
%define GL_RGBA32UI                       0x8D70
%define GL_RGB32UI                        0x8D71
%define GL_RGBA16UI                       0x8D76
%define GL_RGB16UI                        0x8D77
%define GL_RGBA8UI                        0x8D7C
%define GL_RGB8UI                         0x8D7D
%define GL_RGBA32I                        0x8D82
%define GL_RGB32I                         0x8D83
%define GL_RGBA16I                        0x8D88
%define GL_RGB16I                         0x8D89
%define GL_RGBA8I                         0x8D8E
%define GL_RGB8I                          0x8D8F
%define GL_RED_INTEGER                    0x8D94
%define GL_GREEN_INTEGER                  0x8D95
%define GL_BLUE_INTEGER                   0x8D96
%define GL_RGB_INTEGER                    0x8D98
%define GL_RGBA_INTEGER                   0x8D99
%define GL_BGR_INTEGER                    0x8D9A
%define GL_BGRA_INTEGER                   0x8D9B
%define GL_SAMPLER_1D_ARRAY               0x8DC0
%define GL_SAMPLER_2D_ARRAY               0x8DC1
%define GL_SAMPLER_1D_ARRAY_SHADOW        0x8DC3
%define GL_SAMPLER_2D_ARRAY_SHADOW        0x8DC4
%define GL_SAMPLER_CUBE_SHADOW            0x8DC5
%define GL_UNSIGNED_INT_VEC2              0x8DC6
%define GL_UNSIGNED_INT_VEC3              0x8DC7
%define GL_UNSIGNED_INT_VEC4              0x8DC8
%define GL_INT_SAMPLER_1D                 0x8DC9
%define GL_INT_SAMPLER_2D                 0x8DCA
%define GL_INT_SAMPLER_3D                 0x8DCB
%define GL_INT_SAMPLER_CUBE               0x8DCC
%define GL_INT_SAMPLER_1D_ARRAY           0x8DCE
%define GL_INT_SAMPLER_2D_ARRAY           0x8DCF
%define GL_UNSIGNED_INT_SAMPLER_1D        0x8DD1
%define GL_UNSIGNED_INT_SAMPLER_2D        0x8DD2
%define GL_UNSIGNED_INT_SAMPLER_3D        0x8DD3
%define GL_UNSIGNED_INT_SAMPLER_CUBE      0x8DD4
%define GL_UNSIGNED_INT_SAMPLER_1D_ARRAY  0x8DD6
%define GL_UNSIGNED_INT_SAMPLER_2D_ARRAY  0x8DD7
%define GL_QUERY_WAIT                     0x8E13
%define GL_QUERY_NO_WAIT                  0x8E14
%define GL_QUERY_BY_REGION_WAIT           0x8E15
%define GL_QUERY_BY_REGION_NO_WAIT        0x8E16
%define GL_BUFFER_ACCESS_FLAGS            0x911F
%define GL_BUFFER_MAP_LENGTH              0x9120
%define GL_BUFFER_MAP_OFFSET              0x9121
%define GL_DEPTH_COMPONENT32F             0x8CAC
%define GL_DEPTH32F_STENCIL8              0x8CAD
%define GL_FLOAT_32_UNSIGNED_INT_24_8_REV 0x8DAD
%define GL_INVALID_FRAMEBUFFER_OPERATION  0x0506
%define GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING 0x8210
%define GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE 0x8211
%define GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE 0x8212
%define GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE 0x8213
%define GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE 0x8214
%define GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE 0x8215
%define GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE 0x8216
%define GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE 0x8217
%define GL_FRAMEBUFFER_DEFAULT            0x8218
%define GL_FRAMEBUFFER_UNDEFINED          0x8219
%define GL_DEPTH_STENCIL_ATTACHMENT       0x821A
%define GL_MAX_RENDERBUFFER_SIZE          0x84E8
%define GL_DEPTH_STENCIL                  0x84F9
%define GL_UNSIGNED_INT_24_8              0x84FA
%define GL_DEPTH24_STENCIL8               0x88F0
%define GL_TEXTURE_STENCIL_SIZE           0x88F1
%define GL_TEXTURE_RED_TYPE               0x8C10
%define GL_TEXTURE_GREEN_TYPE             0x8C11
%define GL_TEXTURE_BLUE_TYPE              0x8C12
%define GL_TEXTURE_ALPHA_TYPE             0x8C13
%define GL_TEXTURE_DEPTH_TYPE             0x8C16
%define GL_UNSIGNED_NORMALIZED            0x8C17
%define GL_FRAMEBUFFER_BINDING            0x8CA6
%define GL_DRAW_FRAMEBUFFER_BINDING       0x8CA6
%define GL_RENDERBUFFER_BINDING           0x8CA7
%define GL_READ_FRAMEBUFFER               0x8CA8
%define GL_DRAW_FRAMEBUFFER               0x8CA9
%define GL_READ_FRAMEBUFFER_BINDING       0x8CAA
%define GL_RENDERBUFFER_SAMPLES           0x8CAB
%define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE 0x8CD0
%define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME 0x8CD1
%define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL 0x8CD2
%define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE 0x8CD3
%define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER 0x8CD4
%define GL_FRAMEBUFFER_COMPLETE           0x8CD5
%define GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT 0x8CD6
%define GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT 0x8CD7
%define GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER 0x8CDB
%define GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER 0x8CDC
%define GL_FRAMEBUFFER_UNSUPPORTED        0x8CDD
%define GL_MAX_COLOR_ATTACHMENTS          0x8CDF
%define GL_COLOR_ATTACHMENT0              0x8CE0
%define GL_COLOR_ATTACHMENT1              0x8CE1
%define GL_COLOR_ATTACHMENT2              0x8CE2
%define GL_COLOR_ATTACHMENT3              0x8CE3
%define GL_COLOR_ATTACHMENT4              0x8CE4
%define GL_COLOR_ATTACHMENT5              0x8CE5
%define GL_COLOR_ATTACHMENT6              0x8CE6
%define GL_COLOR_ATTACHMENT7              0x8CE7
%define GL_COLOR_ATTACHMENT8              0x8CE8
%define GL_COLOR_ATTACHMENT9              0x8CE9
%define GL_COLOR_ATTACHMENT10             0x8CEA
%define GL_COLOR_ATTACHMENT11             0x8CEB
%define GL_COLOR_ATTACHMENT12             0x8CEC
%define GL_COLOR_ATTACHMENT13             0x8CED
%define GL_COLOR_ATTACHMENT14             0x8CEE
%define GL_COLOR_ATTACHMENT15             0x8CEF
%define GL_COLOR_ATTACHMENT16             0x8CF0
%define GL_COLOR_ATTACHMENT17             0x8CF1
%define GL_COLOR_ATTACHMENT18             0x8CF2
%define GL_COLOR_ATTACHMENT19             0x8CF3
%define GL_COLOR_ATTACHMENT20             0x8CF4
%define GL_COLOR_ATTACHMENT21             0x8CF5
%define GL_COLOR_ATTACHMENT22             0x8CF6
%define GL_COLOR_ATTACHMENT23             0x8CF7
%define GL_COLOR_ATTACHMENT24             0x8CF8
%define GL_COLOR_ATTACHMENT25             0x8CF9
%define GL_COLOR_ATTACHMENT26             0x8CFA
%define GL_COLOR_ATTACHMENT27             0x8CFB
%define GL_COLOR_ATTACHMENT28             0x8CFC
%define GL_COLOR_ATTACHMENT29             0x8CFD
%define GL_COLOR_ATTACHMENT30             0x8CFE
%define GL_COLOR_ATTACHMENT31             0x8CFF
%define GL_DEPTH_ATTACHMENT               0x8D00
%define GL_STENCIL_ATTACHMENT             0x8D20
%define GL_FRAMEBUFFER                    0x8D40
%define GL_RENDERBUFFER                   0x8D41
%define GL_RENDERBUFFER_WIDTH             0x8D42
%define GL_RENDERBUFFER_HEIGHT            0x8D43
%define GL_RENDERBUFFER_INTERNAL_FORMAT   0x8D44
%define GL_STENCIL_INDEX1                 0x8D46
%define GL_STENCIL_INDEX4                 0x8D47
%define GL_STENCIL_INDEX8                 0x8D48
%define GL_STENCIL_INDEX16                0x8D49
%define GL_RENDERBUFFER_RED_SIZE          0x8D50
%define GL_RENDERBUFFER_GREEN_SIZE        0x8D51
%define GL_RENDERBUFFER_BLUE_SIZE         0x8D52
%define GL_RENDERBUFFER_ALPHA_SIZE        0x8D53
%define GL_RENDERBUFFER_DEPTH_SIZE        0x8D54
%define GL_RENDERBUFFER_STENCIL_SIZE      0x8D55
%define GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE 0x8D56
%define GL_MAX_SAMPLES                    0x8D57
%define GL_INDEX                          0x8222
%define GL_TEXTURE_LUMINANCE_TYPE         0x8C14
%define GL_TEXTURE_INTENSITY_TYPE         0x8C15
%define GL_FRAMEBUFFER_SRGB               0x8DB9
%define GL_HALF_FLOAT                     0x140B
%define GL_MAP_READ_BIT                   0x0001
%define GL_MAP_WRITE_BIT                  0x0002
%define GL_MAP_INVALIDATE_RANGE_BIT       0x0004
%define GL_MAP_INVALIDATE_BUFFER_BIT      0x0008
%define GL_MAP_FLUSH_EXPLICIT_BIT         0x0010
%define GL_MAP_UNSYNCHRONIZED_BIT         0x0020
%define GL_COMPRESSED_RED_RGTC1           0x8DBB
%define GL_COMPRESSED_SIGNED_RED_RGTC1    0x8DBC
%define GL_COMPRESSED_RG_RGTC2            0x8DBD
%define GL_COMPRESSED_SIGNED_RG_RGTC2     0x8DBE
%define GL_RG                             0x8227
%define GL_RG_INTEGER                     0x8228
%define GL_R8                             0x8229
%define GL_R16                            0x822A
%define GL_RG8                            0x822B
%define GL_RG16                           0x822C
%define GL_R16F                           0x822D
%define GL_R32F                           0x822E
%define GL_RG16F                          0x822F
%define GL_RG32F                          0x8230
%define GL_R8I                            0x8231
%define GL_R8UI                           0x8232
%define GL_R16I                           0x8233
%define GL_R16UI                          0x8234
%define GL_R32I                           0x8235
%define GL_R32UI                          0x8236
%define GL_RG8I                           0x8237
%define GL_RG8UI                          0x8238
%define GL_RG16I                          0x8239
%define GL_RG16UI                         0x823A
%define GL_RG32I                          0x823B
%define GL_RG32UI                         0x823C
%define GL_VERTEX_ARRAY_BINDING           0x85B5
%define GL_CLAMP_VERTEX_COLOR             0x891A
%define GL_CLAMP_FRAGMENT_COLOR           0x891B
%define GL_ALPHA_INTEGER                  0x8D97

%define GL_SAMPLER_2D_RECT                0x8B63
%define GL_SAMPLER_2D_RECT_SHADOW         0x8B64
%define GL_SAMPLER_BUFFER                 0x8DC2
%define GL_INT_SAMPLER_2D_RECT            0x8DCD
%define GL_INT_SAMPLER_BUFFER             0x8DD0
%define GL_UNSIGNED_INT_SAMPLER_2D_RECT   0x8DD5
%define GL_UNSIGNED_INT_SAMPLER_BUFFER    0x8DD8
%define GL_TEXTURE_BUFFER                 0x8C2A
%define GL_MAX_TEXTURE_BUFFER_SIZE        0x8C2B
%define GL_TEXTURE_BINDING_BUFFER         0x8C2C
%define GL_TEXTURE_BUFFER_DATA_STORE_BINDING 0x8C2D
%define GL_TEXTURE_RECTANGLE              0x84F5
%define GL_TEXTURE_BINDING_RECTANGLE      0x84F6
%define GL_PROXY_TEXTURE_RECTANGLE        0x84F7
%define GL_MAX_RECTANGLE_TEXTURE_SIZE     0x84F8
%define GL_R8_SNORM                       0x8F94
%define GL_RG8_SNORM                      0x8F95
%define GL_RGB8_SNORM                     0x8F96
%define GL_RGBA8_SNORM                    0x8F97
%define GL_R16_SNORM                      0x8F98
%define GL_RG16_SNORM                     0x8F99
%define GL_RGB16_SNORM                    0x8F9A
%define GL_RGBA16_SNORM                   0x8F9B
%define GL_SIGNED_NORMALIZED              0x8F9C
%define GL_PRIMITIVE_RESTART              0x8F9D
%define GL_PRIMITIVE_RESTART_INDEX        0x8F9E
%define GL_COPY_READ_BUFFER               0x8F36
%define GL_COPY_WRITE_BUFFER              0x8F37
%define GL_UNIFORM_BUFFER                 0x8A11
%define GL_UNIFORM_BUFFER_BINDING         0x8A28
%define GL_UNIFORM_BUFFER_START           0x8A29
%define GL_UNIFORM_BUFFER_SIZE            0x8A2A
%define GL_MAX_VERTEX_UNIFORM_BLOCKS      0x8A2B
%define GL_MAX_GEOMETRY_UNIFORM_BLOCKS    0x8A2C
%define GL_MAX_FRAGMENT_UNIFORM_BLOCKS    0x8A2D
%define GL_MAX_COMBINED_UNIFORM_BLOCKS    0x8A2E
%define GL_MAX_UNIFORM_BUFFER_BINDINGS    0x8A2F
%define GL_MAX_UNIFORM_BLOCK_SIZE         0x8A30
%define GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS 0x8A31
%define GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS 0x8A32
%define GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS 0x8A33
%define GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT 0x8A34
%define GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH 0x8A35
%define GL_ACTIVE_UNIFORM_BLOCKS          0x8A36
%define GL_UNIFORM_TYPE                   0x8A37
%define GL_UNIFORM_SIZE                   0x8A38
%define GL_UNIFORM_NAME_LENGTH            0x8A39
%define GL_UNIFORM_BLOCK_INDEX            0x8A3A
%define GL_UNIFORM_OFFSET                 0x8A3B
%define GL_UNIFORM_ARRAY_STRIDE           0x8A3C
%define GL_UNIFORM_MATRIX_STRIDE          0x8A3D
%define GL_UNIFORM_IS_ROW_MAJOR           0x8A3E
%define GL_UNIFORM_BLOCK_BINDING          0x8A3F
%define GL_UNIFORM_BLOCK_DATA_SIZE        0x8A40
%define GL_UNIFORM_BLOCK_NAME_LENGTH      0x8A41
%define GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS  0x8A42
%define GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES 0x8A43
%define GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER 0x8A44
%define GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER 0x8A45
%define GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER 0x8A46
%define GL_INVALID_INDEX                  0xFFFFFFFFu

%define GL_CONTEXT_CORE_PROFILE_BIT       0x00000001
%define GL_CONTEXT_COMPATIBILITY_PROFILE_BIT 0x00000002
%define GL_LINES_ADJACENCY                0x000A
%define GL_LINE_STRIP_ADJACENCY           0x000B
%define GL_TRIANGLES_ADJACENCY            0x000C
%define GL_TRIANGLE_STRIP_ADJACENCY       0x000D
%define GL_PROGRAM_POINT_SIZE             0x8642
%define GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS 0x8C29
%define GL_FRAMEBUFFER_ATTACHMENT_LAYERED 0x8DA7
%define GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS 0x8DA8
%define GL_GEOMETRY_SHADER                0x8DD9
%define GL_GEOMETRY_VERTICES_OUT          0x8916
%define GL_GEOMETRY_INPUT_TYPE            0x8917
%define GL_GEOMETRY_OUTPUT_TYPE           0x8918
%define GL_MAX_GEOMETRY_UNIFORM_COMPONENTS 0x8DDF
%define GL_MAX_GEOMETRY_OUTPUT_VERTICES   0x8DE0
%define GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS 0x8DE1
%define GL_MAX_VERTEX_OUTPUT_COMPONENTS   0x9122
%define GL_MAX_GEOMETRY_INPUT_COMPONENTS  0x9123
%define GL_MAX_GEOMETRY_OUTPUT_COMPONENTS 0x9124
%define GL_MAX_FRAGMENT_INPUT_COMPONENTS  0x9125
%define GL_CONTEXT_PROFILE_MASK           0x9126
%define GL_DEPTH_CLAMP                    0x864F
%define GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION 0x8E4C
%define GL_FIRST_VERTEX_CONVENTION        0x8E4D
%define GL_LAST_VERTEX_CONVENTION         0x8E4E
%define GL_PROVOKING_VERTEX               0x8E4F
%define GL_TEXTURE_CUBE_MAP_SEAMLESS      0x884F
%define GL_MAX_SERVER_WAIT_TIMEOUT        0x9111
%define GL_OBJECT_TYPE                    0x9112
%define GL_SYNC_CONDITION                 0x9113
%define GL_SYNC_STATUS                    0x9114
%define GL_SYNC_FLAGS                     0x9115
%define GL_SYNC_FENCE                     0x9116
%define GL_SYNC_GPU_COMMANDS_COMPLETE     0x9117
%define GL_UNSIGNALED                     0x9118
%define GL_SIGNALED                       0x9119
%define GL_ALREADY_SIGNALED               0x911A
%define GL_TIMEOUT_EXPIRED                0x911B
%define GL_CONDITION_SATISFIED            0x911C
%define GL_WAIT_FAILED                    0x911D
%define GL_TIMEOUT_IGNORED                0xFFFFFFFFFFFFFFFFull
%define GL_SYNC_FLUSH_COMMANDS_BIT        0x00000001
%define GL_SAMPLE_POSITION                0x8E50
%define GL_SAMPLE_MASK                    0x8E51
%define GL_SAMPLE_MASK_VALUE              0x8E52
%define GL_MAX_SAMPLE_MASK_WORDS          0x8E59
%define GL_TEXTURE_2D_MULTISAMPLE         0x9100
%define GL_PROXY_TEXTURE_2D_MULTISAMPLE   0x9101
%define GL_TEXTURE_2D_MULTISAMPLE_ARRAY   0x9102
%define GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY 0x9103
%define GL_TEXTURE_BINDING_2D_MULTISAMPLE 0x9104
%define GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY 0x9105
%define GL_TEXTURE_SAMPLES                0x9106
%define GL_TEXTURE_FIXED_SAMPLE_LOCATIONS 0x9107
%define GL_SAMPLER_2D_MULTISAMPLE         0x9108
%define GL_INT_SAMPLER_2D_MULTISAMPLE     0x9109
%define GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE 0x910A
%define GL_SAMPLER_2D_MULTISAMPLE_ARRAY   0x910B
%define GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY 0x910C
%define GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY 0x910D
%define GL_MAX_COLOR_TEXTURE_SAMPLES      0x910E
%define GL_MAX_DEPTH_TEXTURE_SAMPLES      0x910F
%define GL_MAX_INTEGER_SAMPLES            0x9110

%define GL_VERTEX_ATTRIB_ARRAY_DIVISOR    0x88FE
%define GL_SRC1_COLOR                     0x88F9
%define GL_ONE_MINUS_SRC1_COLOR           0x88FA
%define GL_ONE_MINUS_SRC1_ALPHA           0x88FB
%define GL_MAX_DUAL_SOURCE_DRAW_BUFFERS   0x88FC
%define GL_ANY_SAMPLES_PASSED             0x8C2F
%define GL_SAMPLER_BINDING                0x8919
%define GL_RGB10_A2UI                     0x906F
%define GL_TEXTURE_SWIZZLE_R              0x8E42
%define GL_TEXTURE_SWIZZLE_G              0x8E43
%define GL_TEXTURE_SWIZZLE_B              0x8E44
%define GL_TEXTURE_SWIZZLE_A              0x8E45
%define GL_TEXTURE_SWIZZLE_RGBA           0x8E46
%define GL_TIME_ELAPSED                   0x88BF
%define GL_TIMESTAMP                      0x8E28
%define GL_INT_2_10_10_10_REV             0x8D9F

%ifndef GL_NO_FUNC_IMPORT
	import_dll_func wglGetProcAddress
	import_dll_func wglCreateContext
	import_dll_func wglDeleteContext
	import_dll_func wglMakeCurrent
	import_dll_func wglSwapBuffers
	import_dll_func wglSwapInterval

	import_dll_func glCullFace
	import_dll_func glFrontFace
	import_dll_func glHint
	import_dll_func glLineWidth
	import_dll_func glPointSize
	import_dll_func glPolygonMode
	import_dll_func glScissor
	import_dll_func glTexParameterf
	import_dll_func glTexParameterfv
	import_dll_func glTexParameteri
	import_dll_func glTexParameteriv
	import_dll_func glTexImage1D
	import_dll_func glTexImage2D
	import_dll_func glDrawBuffer
	import_dll_func glClear
	import_dll_func glClearColor
	import_dll_func glClearStencil
	import_dll_func glClearDepth
	import_dll_func glStencilMask
	import_dll_func glColorMask
	import_dll_func glDepthMask
	import_dll_func glDisable
	import_dll_func glEnable
	import_dll_func glFinish
	import_dll_func glFlush
	import_dll_func glBlendFunc
	import_dll_func glLogicOp
	import_dll_func glStencilFunc
	import_dll_func glStencilOp
	import_dll_func glDepthFunc
	import_dll_func glPixelStoref
	import_dll_func glPixelStorei
	import_dll_func glReadBuffer
	import_dll_func glReadPixels
	import_dll_func glGetBooleanv
	import_dll_func glGetDoublev
	import_dll_func glGetError
	import_dll_func glGetFloatv
	import_dll_func glGetIntegerv
	import_dll_func glGetString
	import_dll_func glGetTexImage
	import_dll_func glGetTexParameterfv
	import_dll_func glGetTexParameteriv
	import_dll_func glGetTexLevelParameterfv
	import_dll_func glGetTexLevelParameteriv
	import_dll_func glIsEnabled
	import_dll_func glDepthRange
	import_dll_func glViewport

	import_dll_func glDrawArrays
	import_dll_func glDrawElements
	import_dll_func glGetPointerv
	import_dll_func glPolygonOffset
	import_dll_func glCopyTexImage1D
	import_dll_func glCopyTexImage2D
	import_dll_func glCopyTexSubImage1D
	import_dll_func glCopyTexSubImage2D
	import_dll_func glTexSubImage1D
	import_dll_func glTexSubImage2D
	import_dll_func glBindTexture
	import_dll_func glDeleteTextures
	import_dll_func glGenTextures

	import_dll_func glDrawRangeElements
	import_dll_func glTexImage3D
	import_dll_func glTexSubImage3D
	import_dll_func glCopyTexSubImage3D

	import_dll_func glActiveTexture
	import_dll_func glSampleCoverage
	import_dll_func glCompressedTexImage3D
	import_dll_func glCompressedTexImage2D
	import_dll_func glCompressedTexImage1D
	import_dll_func glCompressedTexSubImage3D
	import_dll_func glCompressedTexSubImage2D
	import_dll_func glCompressedTexSubImage1D
	import_dll_func glGetCompressedTexImage
	import_dll_func glClientActiveTexture
	import_dll_func glMultiTexCoord1d
	import_dll_func glMultiTexCoord1dv
	import_dll_func glMultiTexCoord1f
	import_dll_func glMultiTexCoord1fv
	import_dll_func glMultiTexCoord1i
	import_dll_func glMultiTexCoord1iv
	import_dll_func glMultiTexCoord1s
	import_dll_func glMultiTexCoord1sv
	import_dll_func glMultiTexCoord2d
	import_dll_func glMultiTexCoord2dv
	import_dll_func glMultiTexCoord2f
	import_dll_func glMultiTexCoord2fv
	import_dll_func glMultiTexCoord2i
	import_dll_func glMultiTexCoord2iv
	import_dll_func glMultiTexCoord2s
	import_dll_func glMultiTexCoord2sv
	import_dll_func glMultiTexCoord3d
	import_dll_func glMultiTexCoord3dv
	import_dll_func glMultiTexCoord3f
	import_dll_func glMultiTexCoord3fv
	import_dll_func glMultiTexCoord3i
	import_dll_func glMultiTexCoord3iv
	import_dll_func glMultiTexCoord3s
	import_dll_func glMultiTexCoord3sv
	import_dll_func glMultiTexCoord4d
	import_dll_func glMultiTexCoord4dv
	import_dll_func glMultiTexCoord4f
	import_dll_func glMultiTexCoord4fv
	import_dll_func glMultiTexCoord4i
	import_dll_func glMultiTexCoord4iv
	import_dll_func glMultiTexCoord4s
	import_dll_func glMultiTexCoord4sv
	import_dll_func glLoadTransposeMatrixf
	import_dll_func glLoadTransposeMatrixd
	import_dll_func glMultTransposeMatrixf
	import_dll_func glMultTransposeMatrixd

	import_dll_func glBlendFuncSeparate
	import_dll_func glMultiDrawArrays
	import_dll_func glMultiDrawElements
	import_dll_func glPointParameterf
	import_dll_func glPointParameterfv
	import_dll_func glPointParameteri
	import_dll_func glPointParameteriv
	import_dll_func glFogCoordf
	import_dll_func glFogCoordfv
	import_dll_func glFogCoordd
	import_dll_func glFogCoorddv
	import_dll_func glFogCoordPointer
	import_dll_func glSecondaryColor3b
	import_dll_func glSecondaryColor3bv
	import_dll_func glSecondaryColor3d
	import_dll_func glSecondaryColor3dv
	import_dll_func glSecondaryColor3f
	import_dll_func glSecondaryColor3fv
	import_dll_func glSecondaryColor3i
	import_dll_func glSecondaryColor3iv
	import_dll_func glSecondaryColor3s
	import_dll_func glSecondaryColor3sv
	import_dll_func glSecondaryColor3ub
	import_dll_func glSecondaryColor3ubv
	import_dll_func glSecondaryColor3ui
	import_dll_func glSecondaryColor3uiv
	import_dll_func glSecondaryColor3us
	import_dll_func glSecondaryColor3usv
	import_dll_func glSecondaryColorPointer
	import_dll_func glWindowPos2d
	import_dll_func glWindowPos2dv
	import_dll_func glWindowPos2f
	import_dll_func glWindowPos2fv
	import_dll_func glWindowPos2i
	import_dll_func glWindowPos2iv
	import_dll_func glWindowPos2s
	import_dll_func glWindowPos2sv
	import_dll_func glWindowPos3d
	import_dll_func glWindowPos3dv
	import_dll_func glWindowPos3f
	import_dll_func glWindowPos3fv
	import_dll_func glWindowPos3i
	import_dll_func glWindowPos3iv
	import_dll_func glWindowPos3s
	import_dll_func glWindowPos3sv
	import_dll_func glBlendColor
	import_dll_func glBlendEquation

	import_dll_func glGenQueries
	import_dll_func glDeleteQueries
	import_dll_func glIsQuery
	import_dll_func glBeginQuery
	import_dll_func glEndQuery
	import_dll_func glGetQueryiv
	import_dll_func glGetQueryObjectiv
	import_dll_func glGetQueryObjectuiv
	import_dll_func glBindBuffer
	import_dll_func glDeleteBuffers
	import_dll_func glGenBuffers
	import_dll_func glIsBuffer
	import_dll_func glBufferData
	import_dll_func glBufferSubData
	import_dll_func glGetBufferSubData
	import_dll_func glMapBuffer
	import_dll_func glUnmapBuffer
	import_dll_func glGetBufferParameteriv
	import_dll_func glGetBufferPointerv

	import_dll_func glBlendEquationSeparate
	import_dll_func glDrawBuffers
	import_dll_func glStencilOpSeparate
	import_dll_func glStencilFuncSeparate
	import_dll_func glStencilMaskSeparate
	import_dll_func glAttachShader
	import_dll_func glBindAttribLocation
	import_dll_func glCompileShader
	import_dll_func glCreateProgram
	import_dll_func glCreateShader
	import_dll_func glDeleteProgram
	import_dll_func glDeleteShader
	import_dll_func glDetachShader
	import_dll_func glDisableVertexAttribArray
	import_dll_func glEnableVertexAttribArray
	import_dll_func glGetActiveAttrib
	import_dll_func glGetActiveUniform
	import_dll_func glGetAttachedShaders
	import_dll_func glGetAttribLocation
	import_dll_func glGetProgramiv
	import_dll_func glGetProgramInfoLog
	import_dll_func glGetShaderiv
	import_dll_func glGetShaderInfoLog
	import_dll_func glGetShaderSource
	import_dll_func glGetUniformLocation
	import_dll_func glGetUniformfv
	import_dll_func glGetUniformiv
	import_dll_func glGetVertexAttribdv
	import_dll_func glGetVertexAttribfv
	import_dll_func glGetVertexAttribiv
	import_dll_func glGetVertexAttribPointerv
	import_dll_func glIsProgram
	import_dll_func glIsShader
	import_dll_func glLinkProgram
	import_dll_func glShaderSource
	import_dll_func glUseProgram
	import_dll_func glUniform1f
	import_dll_func glUniform2f
	import_dll_func glUniform3f
	import_dll_func glUniform4f
	import_dll_func glUniform1i
	import_dll_func glUniform2i
	import_dll_func glUniform3i
	import_dll_func glUniform4i
	import_dll_func glUniform1fv
	import_dll_func glUniform2fv
	import_dll_func glUniform3fv
	import_dll_func glUniform4fv
	import_dll_func glUniform1iv
	import_dll_func glUniform2iv
	import_dll_func glUniform3iv
	import_dll_func glUniform4iv
	import_dll_func glUniformMatrix2fv
	import_dll_func glUniformMatrix3fv
	import_dll_func glUniformMatrix4fv
	import_dll_func glValidateProgram
	import_dll_func glVertexAttrib1d
	import_dll_func glVertexAttrib1dv
	import_dll_func glVertexAttrib1f
	import_dll_func glVertexAttrib1fv
	import_dll_func glVertexAttrib1s
	import_dll_func glVertexAttrib1sv
	import_dll_func glVertexAttrib2d
	import_dll_func glVertexAttrib2dv
	import_dll_func glVertexAttrib2f
	import_dll_func glVertexAttrib2fv
	import_dll_func glVertexAttrib2s
	import_dll_func glVertexAttrib2sv
	import_dll_func glVertexAttrib3d
	import_dll_func glVertexAttrib3dv
	import_dll_func glVertexAttrib3f
	import_dll_func glVertexAttrib3fv
	import_dll_func glVertexAttrib3s
	import_dll_func glVertexAttrib3sv
	import_dll_func glVertexAttrib4Nbv
	import_dll_func glVertexAttrib4Niv
	import_dll_func glVertexAttrib4Nsv
	import_dll_func glVertexAttrib4Nub
	import_dll_func glVertexAttrib4Nubv
	import_dll_func glVertexAttrib4Nuiv
	import_dll_func glVertexAttrib4Nusv
	import_dll_func glVertexAttrib4bv
	import_dll_func glVertexAttrib4d
	import_dll_func glVertexAttrib4dv
	import_dll_func glVertexAttrib4f
	import_dll_func glVertexAttrib4fv
	import_dll_func glVertexAttrib4iv
	import_dll_func glVertexAttrib4s
	import_dll_func glVertexAttrib4sv
	import_dll_func glVertexAttrib4ubv
	import_dll_func glVertexAttrib4uiv
	import_dll_func glVertexAttrib4usv
	import_dll_func glVertexAttribPointer

	import_dll_func glUniformMatrix2x3fv
	import_dll_func glUniformMatrix3x2fv
	import_dll_func glUniformMatrix2x4fv
	import_dll_func glUniformMatrix4x2fv
	import_dll_func glUniformMatrix3x4fv
	import_dll_func glUniformMatrix4x3fv

	import_dll_func glColorMaski
	import_dll_func glGetBooleani_v
	import_dll_func glGetIntegeri_v
	import_dll_func glEnablei
	import_dll_func glDisablei
	import_dll_func glIsEnabledi
	import_dll_func glBeginTransformFeedback
	import_dll_func glEndTransformFeedback
	import_dll_func glBindBufferRange
	import_dll_func glBindBufferBase
	import_dll_func glTransformFeedbackVaryings
	import_dll_func glGetTransformFeedbackVarying
	import_dll_func glClampColor
	import_dll_func glBeginConditionalRender
	import_dll_func glEndConditionalRender
	import_dll_func glVertexAttribIPointer
	import_dll_func glGetVertexAttribIiv
	import_dll_func glGetVertexAttribIuiv
	import_dll_func glVertexAttribI1i
	import_dll_func glVertexAttribI2i
	import_dll_func glVertexAttribI3i
	import_dll_func glVertexAttribI4i
	import_dll_func glVertexAttribI1ui
	import_dll_func glVertexAttribI2ui
	import_dll_func glVertexAttribI3ui
	import_dll_func glVertexAttribI4ui
	import_dll_func glVertexAttribI1iv
	import_dll_func glVertexAttribI2iv
	import_dll_func glVertexAttribI3iv
	import_dll_func glVertexAttribI4iv
	import_dll_func glVertexAttribI1uiv
	import_dll_func glVertexAttribI2uiv
	import_dll_func glVertexAttribI3uiv
	import_dll_func glVertexAttribI4uiv
	import_dll_func glVertexAttribI4bv
	import_dll_func glVertexAttribI4sv
	import_dll_func glVertexAttribI4ubv
	import_dll_func glVertexAttribI4usv
	import_dll_func glGetUniformuiv
	import_dll_func glBindFragDataLocation
	import_dll_func glGetFragDataLocation
	import_dll_func glUniform1ui
	import_dll_func glUniform2ui
	import_dll_func glUniform3ui
	import_dll_func glUniform4ui
	import_dll_func glUniform1uiv
	import_dll_func glUniform2uiv
	import_dll_func glUniform3uiv
	import_dll_func glUniform4uiv
	import_dll_func glTexParameterIiv
	import_dll_func glTexParameterIuiv
	import_dll_func glGetTexParameterIiv
	import_dll_func glGetTexParameterIuiv
	import_dll_func glClearBufferiv
	import_dll_func glClearBufferuiv
	import_dll_func glClearBufferfv
	import_dll_func glClearBufferfi
	import_dll_func glGetStringi
	import_dll_func glIsRenderbuffer
	import_dll_func glBindRenderbuffer
	import_dll_func glDeleteRenderbuffers
	import_dll_func glGenRenderbuffers
	import_dll_func glRenderbufferStorage
	import_dll_func glGetRenderbufferParameteriv
	import_dll_func glIsFramebuffer
	import_dll_func glBindFramebuffer
	import_dll_func glDeleteFramebuffers
	import_dll_func glGenFramebuffers
	import_dll_func glCheckFramebufferStatus
	import_dll_func glFramebufferTexture1D
	import_dll_func glFramebufferTexture2D
	import_dll_func glFramebufferTexture3D
	import_dll_func glFramebufferRenderbuffer
	import_dll_func glGetFramebufferAttachmentParameteriv
	import_dll_func glGenerateMipmap
	import_dll_func glBlitFramebuffer
	import_dll_func glRenderbufferStorageMultisample
	import_dll_func glFramebufferTextureLayer
	import_dll_func glMapBufferRange
	import_dll_func glFlushMappedBufferRange
	import_dll_func glBindVertexArray
	import_dll_func glDeleteVertexArrays
	import_dll_func glGenVertexArrays
	import_dll_func glIsVertexArray

	import_dll_func glDrawArraysInstanced
	import_dll_func glDrawElementsInstanced
	import_dll_func glTexBuffer
	import_dll_func glPrimitiveRestartIndex
	import_dll_func glCopyBufferSubData
	import_dll_func glGetUniformIndices
	import_dll_func glGetActiveUniformsiv
	import_dll_func glGetActiveUniformName
	import_dll_func glGetUniformBlockIndex
	import_dll_func glGetActiveUniformBlockiv
	import_dll_func glGetActiveUniformBlockName
	import_dll_func glUniformBlockBinding

	import_dll_func glDrawElementsBaseVertex
	import_dll_func glDrawRangeElementsBaseVertex
	import_dll_func glDrawElementsInstancedBaseVertex
	import_dll_func glMultiDrawElementsBaseVertex
	import_dll_func glProvokingVertex
	import_dll_func glFenceSync
	import_dll_func glIsSync
	import_dll_func glDeleteSync
	import_dll_func glClientWaitSync
	import_dll_func glWaitSync
	import_dll_func glGetInteger64v
	import_dll_func glGetSynciv
	import_dll_func glGetInteger64i_v
	import_dll_func glGetBufferParameteri64v
	import_dll_func glFramebufferTexture
	import_dll_func glTexImage2DMultisample
	import_dll_func glTexImage3DMultisample
	import_dll_func glGetMultisamplefv
	import_dll_func glSampleMaski

	import_dll_func glBindFragDataLocationIndexed
	import_dll_func glGetFragDataIndex
	import_dll_func glGenSamplers
	import_dll_func glDeleteSamplers
	import_dll_func glIsSampler
	import_dll_func glBindSampler
	import_dll_func glSamplerParameteri
	import_dll_func glSamplerParameteriv
	import_dll_func glSamplerParameterf
	import_dll_func glSamplerParameterfv
	import_dll_func glSamplerParameterIiv
	import_dll_func glSamplerParameterIuiv
	import_dll_func glGetSamplerParameteriv
	import_dll_func glGetSamplerParameterIiv
	import_dll_func glGetSamplerParameterfv
	import_dll_func glGetSamplerParameterIuiv
	import_dll_func glQueryCounter
	import_dll_func glGetQueryObjecti64v
	import_dll_func glGetQueryObjectui64v
	import_dll_func glVertexAttribDivisor
	import_dll_func glVertexAttribP1ui
	import_dll_func glVertexAttribP1uiv
	import_dll_func glVertexAttribP2ui
	import_dll_func glVertexAttribP2uiv
	import_dll_func glVertexAttribP3ui
	import_dll_func glVertexAttribP3uiv
	import_dll_func glVertexAttribP4ui
	import_dll_func glVertexAttribP4uiv
	import_dll_func glVertexP2ui
	import_dll_func glVertexP2uiv
	import_dll_func glVertexP3ui
	import_dll_func glVertexP3uiv
	import_dll_func glVertexP4ui
	import_dll_func glVertexP4uiv
	import_dll_func glTexCoordP1ui
	import_dll_func glTexCoordP1uiv
	import_dll_func glTexCoordP2ui
	import_dll_func glTexCoordP2uiv
	import_dll_func glTexCoordP3ui
	import_dll_func glTexCoordP3uiv
	import_dll_func glTexCoordP4ui
	import_dll_func glTexCoordP4uiv
	import_dll_func glMultiTexCoordP1ui
	import_dll_func glMultiTexCoordP1uiv
	import_dll_func glMultiTexCoordP2ui
	import_dll_func glMultiTexCoordP2uiv
	import_dll_func glMultiTexCoordP3ui
	import_dll_func glMultiTexCoordP3uiv
	import_dll_func glMultiTexCoordP4ui
	import_dll_func glMultiTexCoordP4uiv
	import_dll_func glNormalP3ui
	import_dll_func glNormalP3uiv
	import_dll_func glColorP3ui
	import_dll_func glColorP3uiv
	import_dll_func glColorP4ui
	import_dll_func glColorP4uiv
	import_dll_func glSecondaryColorP3ui
	import_dll_func glSecondaryColorP3uiv
%endif

%endif
