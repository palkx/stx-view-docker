/**
 * This script parses tt.xml file into 3 different files: contacts, protocols, targets
 * Code quality is poor, but this script doing his job :)
 */

/* eslint-disable global-require,no-console,prefer-const */
(() => {
  const expat = require('node-expat');
  const fs = require('fs');
  const parser = new expat.Parser('ISO-8859-1');
  // const util = require('util');

  const ttFile = fs.createReadStream(`${__dirname}/tt.xml`);
  const outFileContacts = fs.createWriteStream(`${__dirname}/01-contacts.sql`);
  const outFileProtocols = fs.createWriteStream(`${__dirname}/02-protocols.sql`);
  let outFileTargets = fs.createWriteStream(`${__dirname}/03-targets00.sql`);
  const outFileTargetsFasta = fs.createWriteStream(`${__dirname}/targets.fasta`);

  outFileContacts.write(`CREATE TABLE IF NOT EXISTS tt."contact_info" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "contact_id" text NULL,
  "name" text NULL,
  "address" text NULL,
  "country" text NULL,
  "email" text NULL,
  "organization" text NULL,
  "lab" text NULL,
  "role" text NULL
);

INSERT INTO tt."contact_info" ("original_id", "contact_id", "name", "address", "country", "email", "organization", "lab", "role") VALUES`);

  outFileProtocols.write(`CREATE TABLE IF NOT EXISTS tt."protocols" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "description" text NULL,
  "name" text NULL,
  "text" text NULL,
  "type" text NULL
);

INSERT INTO tt."protocols" ("original_id", "description", "name", "text", "type") VALUES`);

  outFileTargets.write(`CREATE TABLE IF NOT EXISTS tt."targets" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "target_id" text NULL,
  "created_at" timestamp NULL,
  "updated_at" timestamp NULL,
  "laboratory_list" json NULL,
  "contact_info_list" json NULL,
  "projects_list" json NULL,
  "target_rationale" text NULL,
  "target_category_list" json NULL,
  "status" text NULL,
  "url" text NULL,
  "target_sequence_list" json NULL,
  "one_letter_code" text NULL,
  "remark" text NULL,
  "database_list" json NULL,
  "trial_list" json NULL
);

INSERT INTO tt."targets" ("original_id", "target_id", "created_at", "updated_at", "laboratory_list", "contact_info_list", "projects_list", "target_rationale", "target_category_list", "status", "url", "target_sequence_list", "one_letter_code", "remark", "database_list", "trial_list") VALUES`);

  const formatstr = (str, l) => {
    if (!str) return '';
    const loops = Math.ceil(str.length / l);
    let resp = '';
    for (let i = 0, j = 0; j < loops; i += l, j += 1) {
      resp += `${str.slice(i, i + l)}\n`;
    }
    return resp;
  };

  let i = 0;
  let indentLevel = 0;
  let maxIndent = 0;
  let objPath = null;

  let firstWriteContacts = false;
  let firstWriteProtocols = false;
  let firstWriteTargets = false;
  let totalTargets = 0;
  let currentTargetsFile = 0;

  const updateTargetsFile = () => {
    outFileTargets.write(';\n');
    outFileTargets.close();
    currentTargetsFile += 1;
    outFileTargets = fs.createWriteStream(`${__dirname}/03-targets${currentTargetsFile < 10 ? `0${currentTargetsFile}` : currentTargetsFile}.sql`);
    outFileTargets.write(`CREATE TABLE IF NOT EXISTS tt."targets" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "target_id" text NULL,
  "created_at" timestamp NULL,
  "updated_at" timestamp NULL,
  "laboratory_list" json NULL,
  "contact_info_list" json NULL,
  "projects_list" json NULL,
  "target_rationale" text NULL,
  "target_category_list" json NULL,
  "status" text NULL,
  "url" text NULL,
  "target_sequence_list" json NULL,
  "one_letter_code" text NULL,
  "remark" text NULL,
  "database_list" json NULL,
  "trial_list" json NULL
);

INSERT INTO tt."targets" ("original_id", "target_id", "created_at", "updated_at", "laboratory_list", "contact_info_list", "projects_list", "target_rationale", "target_category_list", "status", "url", "target_sequence_list", "one_letter_code", "remark", "database_list", "trial_list") VALUES`);
    firstWriteTargets = false;
  };

  let contactObj = {
    id: null,
    contactInfoId: null,
    name: null,
    address: null,
    country: null,
    email: null,
    organization: null,
    lab: null,
    role: null,
  };

  let protocolObj = {
    id: null,
    protocolDescription: null,
    protocolId: null,
    protocolName: null,
    protocolText: null,
    protocolType: null,
  };

  let targetObj = {
    id: null,
    targetId: null,
    dateCreated: null,
    dateUpdated: null,
    laboratoryList: [],
    contactInfoRefList: [],
    projectsList: [],
    targetRationale: null,
    targetCategoryList: [],
    status: null,
    url: null,
    targetSequenceList: [],
    oneLetterCode: null,
    remark: null,
    databaseRefList: [],
    trialList: [],
  };

  let targetObjProject = {
    projectName: null,
    projectId: null,
  };

  let targetObjSequence = {
    id: null,
    oneLetterCode: null,
    sequenceType: null,
    sequenceChemicalType: null,
    sequenceConstructType: null,
    sourceOrganism: {
      scientificName: null,
      taxDB: null,
      taxId: null,
    },
    sequenceName: null,
  };

  let targetObjDatabaseRef = {
    databaseName: null,
    databaseId: null,
  };

  let targetObjTrial = {
    id: null,
    dateUpdated: null,
    contactInfoRefList: [],
    status: null,
    statusHistoryList: [],
    stopDetails: {
      stopStatus: null,
      remark: null,
    },
    trialSequenceList: [],
    trialProtocolList: [],
  };

  let targetObjTrialHistory = {
    id: null,
    lab: null,
    status: null,
    dateComplete: null,
    prevStatusHistoryId: null,
  };

  let targetObjTrialSequence = {
    id: null,
    oneLetterCode: null,
  };

  let targetObjTrialProtocol = {
    id: null,
    protocolId: null,
    protocolType: null,
  };

  parser.on('startElement', (name, attr) => {
    indentLevel += 1;
    if (indentLevel > maxIndent) maxIndent = indentLevel;
    objPath = objPath ? `${objPath}|:|${attr && attr.id ? attr.id : name}` : `${attr && attr.id ? attr.id : name}`;
    if (i % 1000 === 0) {
      console.log(`[TargetTrack]: Processed ${i}`);
    }
    i += 1;
  });

  parser.on('endElement', (name) => {
    indentLevel -= 1;
    objPath = objPath.split('|:|').reduce((str, el, ind, arr) => {
      let tmpStr = str;
      if (ind + 1 < arr.length) {
        if (tmpStr !== '') {
          tmpStr = `${str}|:|${el}`;
        } else {
          tmpStr = el;
        }
      }
      return tmpStr;
    }, '');
    if (indentLevel === 0) {
      outFileContacts.write(';\n');
      outFileProtocols.write(';\n');
      outFileTargets.write(';\n');
      outFileContacts.close();
      outFileProtocols.close();
      outFileTargets.close();
      outFileTargetsFasta.close();
    }
  });


  parser.on('text', (text) => {
    if (text && text.replace(/\s/g, '').length && text !== '\n') {
      const arr = objPath.split('|:|');
      const key = arr[arr.length - 1];
      const value = text.replace(/[,\\`']/g, '').replace(/ {2}/g, ' ').trim();

      if (arr[1] === 'contactInfoList') {
        if (!contactObj.id || contactObj.id !== arr[2]) {
          if (contactObj.id === null) {
            contactObj.id = arr[2];
          } else {
            outFileContacts.write(`${firstWriteContacts ? ',\n' : ' '}('${contactObj.id}', '${contactObj.contactInfoId}', '${contactObj.name}', '${contactObj.address}', '${contactObj.country}', '${contactObj.email}', '${contactObj.organization}', '${contactObj.lab}', '${contactObj.role}')`);
            firstWriteContacts = true;
            contactObj = {
              id: null,
              contactInfoId: null,
              name: null,
              address: null,
              country: null,
              email: null,
              organization: null,
              lab: null,
              role: null,
            };
            contactObj.id = arr[2];
          }
        }

        if (['contactInfoId', 'name', 'address', 'country', 'email', 'organization', 'lab', 'role'].includes(key)) {
          if (contactObj[key] === null) {
            contactObj[key] = value;
          } else {
            contactObj[key] += value;
          }
        }
      }

      if (arr[1] === 'protocolList') {
        if (!protocolObj.id || protocolObj.id !== arr[2]) {
          if (protocolObj.id === null) {
            protocolObj.id = arr[2];
          } else {
            outFileProtocols.write(`${firstWriteProtocols ? ',\n' : ' '}('${protocolObj.id}', '${protocolObj.protocolDescription}', '${protocolObj.protocolName}', '${protocolObj.protocolText}', '${protocolObj.protocolType}')`);
            firstWriteProtocols = true;
            protocolObj = {
              id: null,
              protocolDescription: null,
              protocolId: null,
              protocolName: null,
              protocolText: null,
              protocolType: null,
            };
            protocolObj.id = arr[2];
          }
        }

        if (['protocolDescription', 'protocolId', 'protocolName', 'protocolText', 'protocolType'].includes(key)) {
          if (protocolObj[key] === null) {
            protocolObj[key] = value;
          } else {
            protocolObj[key] += value;
          }
        }
      }

      if (arr[1] !== 'protocolList' && arr[1] !== 'contactInfoList' && arr.length > 2) {
        if (!targetObj.id || targetObj.id !== arr[1]) {
          if (targetObj.id === null) {
            targetObj.id = arr[1].replace(/[|]/g, '');
          } else {
            targetObj.trialList.push(targetObjTrial);
            targetObjTrial = {
              id: null,
              dateUpdated: null,
              contactInfoRefList: [],
              status: null,
              statusHistoryList: [],
              stopDetails: {
                stopStatus: null,
                remark: null,
              },
              trialSequenceList: [],
              trialProtocolList: [],
            };
            outFileTargets.write(`${firstWriteTargets ? ',\n' : ' '}('${targetObj.id}','${targetObj.targetId}','${targetObj.dateCreated}','${targetObj.dateUpdated}','${JSON.stringify(targetObj.laboratoryList)}','${JSON.stringify(targetObj.contactInfoRefList)}','${JSON.stringify(targetObj.projectsList)}','${targetObj.targetRationale}','${JSON.stringify(targetObj.targetCategoryList)}','${targetObj.status}','${targetObj.url}','${JSON.stringify(targetObj.targetSequenceList)}','${targetObj.oneLetterCode}','${targetObj.remark}','${JSON.stringify(targetObj.databaseRefList)}','${JSON.stringify(targetObj.trialList)}')`);
            outFileTargetsFasta.write(`>id|${targetObj.id}|status|${targetObj.status}\n${formatstr(targetObj.oneLetterCode, 80)}`);
            firstWriteTargets = true;
            totalTargets += 1;
            if (totalTargets > 10000) {
              totalTargets = 0;
              updateTargetsFile();
            }
            targetObj = {
              id: arr[1],
              targetId: null,
              dateCreated: null,
              dateUpdated: null,
              laboratoryList: [],
              contactInfoRefList: [],
              projectsList: [],
              targetRationale: null,
              targetCategoryList: [],
              status: null,
              url: null,
              targetSequenceList: [],
              oneLetterCode: null,
              remark: null,
              databaseRefList: [],
              trialList: [],
            };
          }
        }

        if (['targetId', 'dateCreated', 'dateUpdated', 'laboratoryList', 'contactInfoRefList', 'lab', 'contactInfoId', 'projectList', 'projectName', 'projectId', 'targetRationale', 'targetCategoryList', 'targetCategoryName', 'status', 'targetSequenceList', 'oneLetterCode', 'sequenceType', 'sequenceChemicalType', 'sequenceConstructType', 'sourceOrganism', 'scientificName', 'taxDB', 'taxId', 'sequenceName', 'remark', 'databaseRefList', 'databaseName', 'databaseId', 'trialList', 'statusHistoryList', 'dateComplete', 'prevStatusHistoryId', 'trialSequenceList', 'trialProtocolList', 'protocolId', 'protocolType', 'url', 'stopStatus'].includes(key)) {
          if (['laboratoryList', 'contactInfoRefList', 'projectList', 'targetCategoryList', 'targetSequenceList', 'databaseRefList', 'trialList'].includes(arr[2])) {
            if (arr[2] === 'laboratoryList' && arr[3]) {
              targetObj.laboratoryList.push(value);
            }
            if (arr[2] === 'contactInfoRefList' && arr[3]) {
              targetObj.contactInfoRefList.push(value);
            }
            if (arr[2] === 'projectList' && arr[3]) {
              if (key === 'projectName' && targetObjProject.projectName !== value && targetObjProject.projectName !== null) {
                targetObj.projectsList.push(targetObjProject);
                targetObjProject = {
                  projectName: value,
                  projectId: null,
                };
              } else {
                targetObjProject[key] = value;
              }
            } else if (targetObjProject.projectName !== null) {
              targetObj.projectsList.push(targetObjProject);
              targetObjProject = {
                projectName: null,
                projectId: null,
              };
            }
            if (arr[2] === 'targetCategoryList' && key === 'targetCategoryName') {
              targetObj.targetCategoryList.push(value);
            }
            if (arr[2] === 'targetSequenceList' && arr[4]) {
              if (targetObjSequence.id === null && arr[3]) {
                targetObjSequence.id = arr[3];
              }
              if (targetObjSequence.id !== arr[3]) {
                targetObj.targetSequenceList.push(targetObjSequence);
                targetObjSequence = {
                  id: arr[3],
                  oneLetterCode: null,
                  sequenceType: null,
                  sequenceChemicalType: null,
                  sequenceConstructType: null,
                  sourceOrganism: {
                    scientificName: null,
                    taxDB: null,
                    taxId: null,
                  },
                  sequenceName: null,
                };
              }
              if (arr[5]) {
                targetObjSequence.sourceOrganism[key] = value;
              } else {
                if (key === 'oneLetterCode') {
                  targetObj.oneLetterCode = value;
                }
                targetObjSequence[key] = value;
              }
            } else if (targetObjSequence.id !== null) {
              targetObj.targetSequenceList.push(targetObjSequence);
              targetObjSequence = {
                id: null,
                oneLetterCode: null,
                sequenceType: null,
                sequenceChemicalType: null,
                sequenceConstructType: null,
                sourceOrganism: {
                  scientificName: null,
                  taxDB: null,
                  taxId: null,
                },
                sequenceName: null,
              };
            }
            if (arr[2] === 'databaseRefList' && arr[3]) {
              if (key === 'databaseName' && targetObjDatabaseRef.databaseName !== value && targetObjDatabaseRef.databaseName !== null) {
                targetObj.databaseRefList.push(targetObjDatabaseRef);
                targetObjDatabaseRef = {
                  databaseName: value,
                  databaseId: null,
                };
              } else {
                targetObjDatabaseRef[key] = value;
              }
            } else if (targetObjDatabaseRef.databaseName !== null) {
              targetObj.databaseRefList.push(targetObjDatabaseRef);
              targetObjDatabaseRef = {
                databaseName: null,
                databaseId: null,
              };
            }

            if (arr[2] === 'trialList' && arr[4]) {
              if (targetObjTrial.id === null && arr[3]) {
                targetObjTrial.id = arr[3];
              }
              if (targetObjTrial.id !== arr[3]) {
                targetObj.trialList.push(targetObjTrial);
                targetObjTrial = {
                  id: arr[3],
                  dateUpdated: null,
                  contactInfoRefList: [],
                  status: null,
                  statusHistoryList: [],
                  stopDetails: {
                    stopStatus: null,
                    remark: null,
                  },
                  trialSequenceList: [],
                  trialProtocolList: [],
                };
              }
              if (['contactInfoRefList', 'statusHistoryList', 'stopDetails', 'trialSequenceList', 'trialProtocolList'].includes(arr[4])) {
                if (arr[4] === 'contactInfoRefList' && key === 'contactInfoId') {
                  targetObjTrial.contactInfoRefList.push(value);
                }
                if (arr[4] === 'statusHistoryList') {
                  if (targetObjTrialHistory.id === null && arr[5]) {
                    targetObjTrialHistory.id = arr[5];
                  }
                  if (targetObjTrialHistory.id !== arr[5]) {
                    targetObjTrial.statusHistoryList.push(targetObjTrialHistory);
                    targetObjTrialHistory = {
                      id: arr[5],
                      lab: null,
                      status: null,
                      dateComplete: null,
                      prevStatusHistoryId: null,
                    };
                  }
                  targetObjTrialHistory[key] = value;
                } else if (targetObjTrialHistory.id !== null) {
                  targetObjTrial.statusHistoryList.push(targetObjTrialHistory);
                  targetObjTrialHistory = {
                    id: null,
                    lab: null,
                    status: null,
                    dateComplete: null,
                    prevStatusHistoryId: null,
                  };
                }
                if (arr[4] === 'stopDetails' && (key === 'remark' || key === 'stopStatus')) {
                  switch (key) {
                    case 'remark':
                      targetObjTrial.stopDetails.remark = value;
                      break;
                    case 'stopStatus':
                      targetObjTrial.stopDetails.stopStatus = value;
                      break;
                    default:
                      break;
                  }
                }
                if (arr[4] === 'trialSequenceList') {
                  if (targetObjTrialSequence.id === null && arr[5]) {
                    targetObjTrialSequence.id = arr[5];
                  }
                  if (targetObjTrialSequence.id !== arr[5]) {
                    targetObjTrial.trialSequenceList.push(targetObjTrialSequence);
                    targetObjTrialSequence = {
                      id: arr[5],
                      oneLetterCode: null,
                    };
                  }
                  targetObjTrialSequence[key] = value;
                } else if (targetObjTrialSequence.id !== null) {
                  targetObjTrial.trialSequenceList.push(targetObjTrialSequence);
                  targetObjTrialSequence = {
                    id: null,
                    oneLetterCode: null,
                  };
                }
                if (arr[4] === 'trialProtocolList') {
                  if (targetObjTrialProtocol.id === null && arr[5]) {
                    targetObjTrialProtocol.id = arr[5];
                  }
                  if (targetObjTrialProtocol.id !== arr[5]) {
                    targetObjTrial.trialProtocolList.push(targetObjTrialProtocol);
                    targetObjTrialProtocol = {
                      id: null,
                      protocolId: null,
                      protocolType: null,
                    };
                  }
                  targetObjTrialProtocol[key] = value;
                } else if (targetObjTrialProtocol.id !== null) {
                  targetObjTrial.trialProtocolList.push(targetObjTrialProtocol);
                  targetObjTrialProtocol = {
                    id: null,
                    protocolId: null,
                    protocolType: null,
                  };
                }
              } else if (targetObjTrial[key] === null || targetObjTrial[key] === value) {
                targetObjTrial[key] = value;
              } else {
                targetObjTrial[key] += value;
              }
              /* eslint-enable */
            }
          } else if (arr.length <= 3) {
            if (targetObj[key] === null || targetObj[key] === value) {
              targetObj[key] = value;
            } else {
              targetObj[key] += value;
            }
          }
        }
      }
    }
  });

  parser.on('error', (error) => {
    console.log(error);
  });

  ttFile.pipe(parser);
})();
